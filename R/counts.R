# Functions that relate to downloading count data into SingleCellExperiments

# We need to load utils now so it can be used at the top level
#' @include utils.R

# Maps user provided assay names to their corresponding paths in the repository
assay_map <- c(
  counts = "counts",
  cpm = "cpm",
  rank = "rank",
  sct = "sct"
)

#' Base URL pointing to the count data at the current version
#' @keywords internal
#' @noRd
COUNTS_URL <- paste0(
  "https://object-store.rc.nectar.org.au/v1/",
  "AUTH_06d6e008e3e642da99d806ba3ea629c5/cellNexus-anndata"
)

#' @inherit get_single_cell_experiment
#' @inheritDotParams get_single_cell_experiment
#' @importFrom cli cli_alert_warning
#' @return A `SingleCellExperiment` object.
#' @export
#' @references Shen, M., Y. Gao, N. Liu, D. Bhuva, M. Milton, J. Henao,
#'   J. Andrews, E. Yang, C. Zhan, N. Liu, S. Si, J. W. Hutchison,
#'   M. H. Shakeel, M. Morgan, A. T. Papenfuss, J. Iskander, J. M. Polo,
#'   and S. Mangiola. "cellNexus: Quality control, annotation, aggregation
#'   and analytical layers for the Human Cell Atlas data." bioRxiv (2026).
#'   doi:10.64898/2026.04.14.718336.
#' @source [Shen et al.,2026](https://www.biorxiv.org/content/10.64898/2026.04.14.718336v3)
get_SingleCellExperiment <- function(...) {
  cli_alert_warning(paste(
    "This function name is deprecated.",
    "Please use {.fun get_single_cell_experiment} instead"
  ))

  get_single_cell_experiment(...)
}

#' Gets a SingleCellExperiment from curated metadata
#'
#' Given a data frame of Curated Atlas metadata obtained from [get_metadata()],
#' returns a [`SingleCellExperiment::SingleCellExperiment-class`] object
#' corresponding to the samples in that data frame
#' @param data A data frame containing, at minimum, `cell_id`, `file_id_cellNexus_single_cell`
#'   and `atlas_id` columns, which correspond to a single cell ID, file subdivision for internal use,
#'   and atlas name in format (e.g cellxgene_2024/0.1.0) for internal use.
#'   They can be obtained from the [get_metadata()] function.
#'   Use `get_atlas_versions()` to download atlas versions data frame.
#' @param assays A character vector specifying the desired assay(s) to be requested.
#'   Valid elements include "counts", "cpm", "rank", and "sct" for single-cell analyses
#'   The default setting retrieves only the counts assay.
#'   If your analysis involves a smaller set of genes, consider using the "cpm" assay.
#'   The "rank" assay is suited for signature calculations across millions of cells.
#' @param cell_aggregation A character vector that specifies which cell aggregation
#'   strategy should be applied. This will create a corresponding subdirectory
#'   in the cache directory. Single cell level is applied by default.
#' @param cache_directory An optional character vector of length one. If
#'   provided, it should indicate a local file path where any remotely accessed
#'   files should be copied.
#' @param repository A character vector of length one. If provided, it should be
#'   an HTTP URL pointing to the location where the single cell data is stored.
#' @param features An optional character vector of features (ie genes) to return
#'   the counts for. By default counts for all features will be returned.
#' @importFrom dplyr pull filter as_tibble inner_join collect transmute group_split
#' @return A `SingleCellExperiment` object.
#' @importFrom tibble column_to_rownames
#' @importFrom BiocGenerics cbind
#' @importFrom glue glue
#' @importFrom SummarizedExperiment colData assayNames<-
#' @importFrom checkmate assert check_subset check_true
#' @importFrom cli cli_alert_success cli_alert_info cli_alert_warning
#' @importFrom rlang .data
#' @importFrom S4Vectors DataFrame
#' @examples
#' # Use the lightweight sample database URL (for fast checks during development only)
#' meta <- get_metadata(cloud_metadata = cellNexus::SAMPLE_DATABASE_URL) |> head(2)
#' sce <- get_single_cell_experiment(meta)
#' @export
#' @references Shen, M., Y. Gao, N. Liu, D. Bhuva, M. Milton, J. Henao,
#'   J. Andrews, E. Yang, C. Zhan, N. Liu, S. Si, J. W. Hutchison,
#'   M. H. Shakeel, M. Morgan, A. T. Papenfuss, J. Iskander, J. M. Polo,
#'   and S. Mangiola. "cellNexus: Quality control, annotation, aggregation
#'   and analytical layers for the Human Cell Atlas data." bioRxiv (2026).
#'   doi:10.64898/2026.04.14.718336.
#' @source [Shen et al.,2026](https://www.biorxiv.org/content/10.64898/2026.04.14.718336v3)
get_single_cell_experiment <- function(data,
                                       assays = "counts",
                                       cell_aggregation = "",
                                       cache_directory = get_default_cache_dir(),
                                       repository = COUNTS_URL,
                                       features = NULL) {
  raw_data <- collect(data)
  assert(
    check_true(inherits(raw_data, "tbl")),
    check_subset(c("cell_id", "file_id_cellNexus_single_cell", "atlas_id"), names(raw_data))
  )

  # The SCT assay is precomputed from quality-controlled cells only, so when
  # SCT is requested we must restrict to QC-passed cells to avoid silent
  # cell-count mismatches. counts / cpm / rank cover all cells and need no
  # such guard.
  if ("sct" %in% assays) {
    n_total <- nrow(raw_data)
    raw_data <- keep_quality_cells(raw_data)
    n_dropped <- n_total - nrow(raw_data)
    if (n_dropped > 0) {
      cli_alert_warning(paste(
        "cellNexus says: {n_dropped} cells in your metadata did not pass quality",
        "control (empty droplets, dead cells, or doublets) and have been excluded",
        "automatically. The SCT assay is computed from quality-controlled cells only.",
        "To suppress this warning, apply `keep_quality_cells()` to your metadata",
        "before calling `get_single_cell_experiment()`."
      ))
    }
  }

  validate_data(raw_data, assays, cell_aggregation, cache_directory, repository, features)

  .fetch_experiments(
    raw_data = raw_data,
    assays = assays,
    cell_aggregation = cell_aggregation,
    cache_directory = cache_directory,
    repository = repository,
    grouping_column = "file_id_cellNexus_single_cell",
    features = features
  )
}

#' Gets a Pseudobulk from curated metadata
#'
#' Given a data frame of Curated Atlas metadata obtained from [get_metadata()],
#' returns a [`SummarizedExperiment::SummarizedExperiment-class`] object
#' corresponding to the samples in that data frame
#'
#' @param data A data frame containing, at minimum, `cell_id`, `file_id_cellNexus_pseudobulk`,
#'   `sample_id`, `cell_type_unified_ensemble`, `atlas_id` columns, which correspond to a single cell ID,
#'   file subdivision for internal use, a singlel cell sample ID, harmonised cell type,
#'   and atlas name in format (e.g cellxgene_2024/0.1.0) for internal use.
#'   They can be obtained from the [get_metadata()] function.
#'   Use `get_atlas_versions()` to download atlas versions data frame.
#' @param assays A character vector specifying the desired assay(s) to be requested.
#'   The default setting retrieves only the counts assay.
#' @param cell_aggregation A character vector that specifies which cell aggregation
#'   strategy should be applied. This will create a corresponding subdirectory
#'   in the cache directory.
#' @param cache_directory An optional character vector of length one. If
#'   provided, it should indicate a local file path where any remotely accessed
#'   files should be copied.
#' @param repository A character vector of length one. If provided, it should be
#'   an HTTP URL pointing to the location where the single cell data is stored.
#' @param features An optional character vector of features (ie genes) to return
#'   the counts for. By default counts for all features will be returned.
#'   When provided, the returned object will contain exactly the requested
#'   features (row order preserved), and any experiments/samples that do not
#'   contain all requested features are dropped. This preserves the full set
#'   of requested features at the cost of potentially fewer samples.
#'   A warning is emitted when samples are dropped.
#' @param as_SummarizedExperiment If `TRUE`, coerce the result to a
#'   `SummarizedExperiment`. Note that `as(x, "SummarizedExperiment")` drops
#'   feature rownames; `get_pseudobulk()` restores them after coercion.
#' @return By default, a `SingleCellExperiment` object. If
#'   `as_SummarizedExperiment` is `TRUE`, a `SummarizedExperiment` object.
#' @importFrom dplyr pull filter as_tibble inner_join collect transmute
#' @importFrom tibble column_to_rownames
#' @importFrom BiocGenerics cbind
#' @importFrom glue glue
#' @importFrom SummarizedExperiment colData assayNames<-
#' @importFrom checkmate assert check_subset check_true
#' @importFrom cli cli_alert_success cli_alert_info cli_alert_warning
#' @importFrom rlang .data
#' @importFrom S4Vectors DataFrame
#' @examples
#' # Use the lightweight sample database URL (for fast checks during development only)
#' meta <- get_metadata(cloud_metadata = cellNexus::SAMPLE_DATABASE_URL) |>
#'   keep_quality_cells() |>
#'   dplyr::filter(cell_type_unified_ensemble == "epithelial")
#' pseudobulk <- meta |> get_pseudobulk()
#' @export
#' @references Shen, M., Y. Gao, N. Liu, D. Bhuva, M. Milton, J. Henao,
#'   J. Andrews, E. Yang, C. Zhan, N. Liu, S. Si, J. W. Hutchison,
#'   M. H. Shakeel, M. Morgan, A. T. Papenfuss, J. Iskander, J. M. Polo,
#'   and S. Mangiola. "cellNexus: Quality control, annotation, aggregation
#'   and analytical layers for the Human Cell Atlas data." bioRxiv (2026).
#'   doi:10.64898/2026.04.14.718336.
#' @source [Shen et al.,2026](https://www.biorxiv.org/content/10.64898/2026.04.14.718336v3)
get_pseudobulk <- function(data,
                           assays = "counts",
                           cell_aggregation = "pseudobulk",
                           cache_directory = get_default_cache_dir(),
                           repository = COUNTS_URL,
                           features = NULL,
                           as_SummarizedExperiment = FALSE) {
  raw_data <- collect(data)
  assert(
    check_true(inherits(raw_data, "tbl")),
    check_subset(c(
      "cell_id", "file_id_cellNexus_pseudobulk", "sample_id", "cell_type_unified_ensemble",
      "atlas_id"
    ), names(raw_data))
  )

  # Pseudobulk h5ad files are computed from quality-controlled cells only.
  # Automatically apply keep_quality_cells() when the QC columns are present so
  # that results are identical regardless of whether the user pre-filters.
  qc_cols <- c("empty_droplet", "alive", "scDblFinder.class")
  if (all(qc_cols %in% names(raw_data))) {
    n_total <- nrow(raw_data)
    raw_data <- keep_quality_cells(raw_data)
    n_dropped <- n_total - nrow(raw_data)
    if (n_dropped > 0) {
      cli_alert_warning(paste(
        "cellNexus says: {n_dropped} cells in your metadata did not pass quality",
        "control (empty droplets, dead cells, or doublets) and have been excluded",
        "automatically. Pseudobulk counts are computed from quality-controlled cells only.",
        "To suppress this warning, apply `keep_quality_cells()` to your metadata",
        "before calling `get_pseudobulk()`."
      ))
    }
  }

  validate_data(raw_data, assays, cell_aggregation, cache_directory, repository, features)

  res <- .fetch_experiments(
    raw_data = raw_data,
    assays = assays,
    cell_aggregation = cell_aggregation,
    cache_directory = cache_directory,
    repository = repository,
    grouping_column = "file_id_cellNexus_pseudobulk",
    features = features
  )

  if (as_SummarizedExperiment) {
    rn <- rownames(res)
    res <- as(res, "SummarizedExperiment")
    rownames(res) <- rn
  }

  res
}

#' Gets a Metacell from curated metadata
#'
#' Given a data frame of Curated Atlas metadata obtained from [get_metadata()],
#' returns a [`SingleCellExperiment::SingleCellExperiment-class`] object
#' corresponding to the samples in that data frame
#'
#' @param data A data frame containing, at minimum, `sample_id`, `file_id_cellNexus_single_cell`,
#'   `atlas_id` and a metacell column (e.g `metacell_2`) columns, which correspond to sample ID
#'   file subdivision for internal use, atlas name in format (e.g cellxgene_2024/0.1.0)
#'   for internal use, and metacell column to be queried.
#'   They can be obtained from the [get_metadata()] function.
#'   Use `get_atlas_versions()` to download atlas versions data frame.
#' @param assays A character vector of metacell counts. Default to "counts".
#' @param cell_aggregation A character vector representing the level of metacell aggregation.
#'   It indicates a group of cells that can be divided into the number of metacells.
#'   Each metacell comprises a minimum of ten single cells by default.
#' @param cache_directory An optional character vector of length one. If
#'   provided, it should indicate a local file path where any remotely accessed
#'   files should be copied.
#' @param repository A character vector of length one. If provided, it should be
#'   an HTTP URL pointing to the location where the single cell data is stored.
#' @param features An optional character vector of features (ie genes) to return
#'   the counts for. By default counts for all features will be returned.
#' @importFrom dplyr pull filter mutate as_tibble inner_join collect transmute group_split
#' @return A `SingleCellExperiment` object.
#' @importFrom tibble column_to_rownames
#' @importFrom BiocGenerics cbind
#' @importFrom glue glue
#' @importFrom SummarizedExperiment colData assayNames<-
#' @importFrom checkmate assert check_subset check_true
#' @importFrom cli cli_alert_success cli_alert_info cli_alert_warning
#' @importFrom rlang .data
#' @importFrom S4Vectors DataFrame
#' @keywords internal
#' @noRd
#' @references Shen, M., Y. Gao, N. Liu, D. Bhuva, M. Milton, J. Henao,
#'   J. Andrews, E. Yang, C. Zhan, N. Liu, S. Si, J. W. Hutchison,
#'   M. H. Shakeel, M. Morgan, A. T. Papenfuss, J. Iskander, J. M. Polo,
#'   and S. Mangiola. "cellNexus: Quality control, annotation, aggregation
#'   and analytical layers for the Human Cell Atlas data." bioRxiv (2026).
#'   doi:10.64898/2026.04.14.718336.
#' @source [Shen et al.,2026](https://www.biorxiv.org/content/10.64898/2026.04.14.718336v3)
get_metacell <- function(data,
                         assays = "counts",
                         cell_aggregation,
                         cache_directory = get_default_cache_dir(),
                         repository = COUNTS_URL,
                         features = NULL) {
  raw_data <- collect(data)
  assert(
    check_true(inherits(raw_data, "tbl")),
    check_subset(c("sample_id", "file_id_cellNexus_single_cell", "atlas_id"), names(raw_data)),
    check_true(any(grepl("^metacell", names(raw_data))))
  )
  # Separate metacell and single_cell in group_to_data_container without
  # producing a repetitive column in the metadata
  raw_data <- raw_data |>
    mutate(file_id_cellNexus_metacell = .data$file_id_cellNexus_single_cell)

  validate_data(data, assays, cell_aggregation, cache_directory, repository, features)

  .fetch_experiments(
    raw_data = raw_data,
    assays = assays,
    cell_aggregation = cell_aggregation,
    cache_directory = cache_directory,
    repository = repository,
    grouping_column = "file_id_cellNexus_metacell",
    features = features,
    metacell_column = cell_aggregation
  )
}

#' Sync, read, filter and compile experiments from cache
#'
#' Shared internal implementation used by [get_single_cell_experiment()],
#' [get_pseudobulk()].  Handles file synchronisation,
#' per-assay reading, feature filtering and experiment assembly.
#'
#' @param raw_data A collected (in-memory) tibble of metadata.
#' @param assays Character vector of assay names.
#' @param cell_aggregation Aggregation level string (e.g. \code{""}, \code{"pseudobulk"}.
#' @param cache_directory Local cache root path.
#' @param repository Base HTTP URL for remote files, or \code{NULL}.
#' @param grouping_column Name of the file-ID column used to group cells.
#' @param features Optional character vector of requested gene features.
#' @param metacell_column Optional character of hierarchy.
#' @return A \code{SingleCellExperiment} or \code{SummarizedExperiment} object.
#' @importFrom httr parse_url
#' @importFrom dplyr transmute distinct mutate
#' @importFrom purrr pmap imap map map_lgl map2 reduce
#' @importFrom cli cli_alert_info cli_alert_warning cli_progress_bar cli_progress_update cli_progress_done
#' @importFrom checkmate assert check_true
#' @importFrom SummarizedExperiment assays<- assayNames assay<-
#' @importFrom BiocGenerics cbind
#' @importFrom rlang .data
#' @keywords internal
#' @noRd
.fetch_experiments <- function(
  raw_data,
  assays,
  cell_aggregation,
  cache_directory,
  repository,
  grouping_column,
  features,
  metacell_column = NULL
) {
  subdirs <- assay_map[assays]

  if (!is.null(repository)) {
    cli_alert_info("Synchronising files")
    parsed_repo <- parse_url(repository)
    assert(check_true(parsed_repo$scheme %in% c("http", "https")))

    # Build complete file list first, then download all in parallel
    file_lists <- raw_data |>
      transmute(
        files = .data[[grouping_column]],
        atlas_name = .data$atlas_id,
        cache_dir = cache_directory
      ) |>
      distinct() |>
      pmap(function(files, atlas_name, cache_dir) {
        build_assay_file_list(
          files = files,
          atlas_name = atlas_name,
          cache_dir = cache_dir,
          url = parsed_repo,
          cell_aggregation = cell_aggregation,
          subdirs = subdirs
        )
      })

    # Combine all file lists and download in one parallel batch
    all_files <- do.call(rbind, file_lists)
    sync_all_assay_files(all_files)
  }

  cli_alert_info("Reading files.")

  # Group by file only, not by dir_prefix
  groups <- raw_data |>
    group_split(.data[[grouping_column]])

  # Outer imap iterates over assays; each assay gets its own labelled progress bar.
  # This also fixes dir_prefix construction: current_subdir is properly scoped here.
  experiments <- imap(subdirs, function(current_subdir, current_assay) {
    base_path <- if (nchar(cell_aggregation) > 0) {
      file.path(cell_aggregation, current_subdir)
    } else {
      current_subdir
    }

    # For SCT, accumulate dropped-cell counts so we can emit one consolidated
    # warning after all files are read. For other assays the per-file warning
    # fires as normal (dropped_counter = NULL).
    cell_drop_state <- if (current_assay == "sct") {
      e <- new.env(parent = emptyenv())
      e$n_dropped <- 0L
      e$n_files_affected <- 0L
      e$sample_ids <- character(0)
      e
    } else {
      NULL
    }

    pb <- cli_progress_bar(glue("Reading {current_assay}"), total = length(groups))

    per_group <- map(seq_along(groups), function(i) {
      gr <- groups[[i]]
      dir_prefix <- file.path(cache_directory, gr$atlas_id[1], base_path)
      res <- group_to_data_container(
        i, gr,
        dir_prefix = dir_prefix,
        features = features,
        grouping_column = grouping_column,
        metacell_column = cell_aggregation,
        dropped_counter = cell_drop_state
      )
      cli_progress_update(id = pb)
      res
    })

    cli_progress_done(id = pb)

    if (!is.null(cell_drop_state) && cell_drop_state$n_dropped > 0L) {
      affected_ids <- paste(cell_drop_state$sample_ids, collapse = ", ")
      cli_alert_warning(paste(
        "cellNexus says: {cell_drop_state$n_dropped} cell(s) from your metadata are",
        "absent from the SCT assay across {cell_drop_state$n_files_affected} file(s).",
        "This is expected: SCT normalisation is run per sample and may fail for",
        "samples with very few cells or extreme count distributions.",
        "The returned object contains only cells from samples where SCT succeeded.",
        "Affected sample_id(s): {affected_ids}."
      ))
    }

    per_group
  })

  # Base experiment list comes from the first assay.
  # Additional assays are slotted into the base SCEs by name.
  experiment_list <- experiments[[1]]

  experiment_list <- reduce(
    names(experiments[-1]),
    function(acc, extra_assay) {
      map2(acc, experiments[[extra_assay]], function(base_exp, extra_exp) {
        assay(base_exp, extra_assay) <- assay(extra_exp, assayNames(extra_exp)[1])
        base_exp
      })
    },
    .init = experiment_list
  )

  # If features provided, drop experiments missing any requested features
  # and align rows to the requested features; otherwise intersect genes.
  if (!is.null(features)) {
    keep_idx <- purrr::map_lgl(experiment_list, function(exp) all(features %in% rownames(exp)))
    dropped_count <- sum(!keep_idx)
    if (all(!keep_idx)) {
      cli_alert_warning("cellNexus says: None of the experiments contain all requested features. Please select different features.")
    } else if (dropped_count > 0) {
      cli_alert_warning("cellNexus says: {dropped_count} experiment(s) were dropped because they did not contain all requested features.")
    }
    experiment_list <- experiment_list[keep_idx]
    experiment_list <- purrr::map(experiment_list, function(exp) exp[features, ])
  } else {
    commonGenes <- experiment_list |>
      check_gene_overlap()
    experiment_list <- map(experiment_list, function(exp) {
      exp[commonGenes, ]
    })
  }

  cli_alert_info("Compiling Experiment.")

  experiment_list |>
    do.call(cbind, args = _)
}

# Keep columns functionally determined by key columns
get_specific_annotation_columns <- function(.data, key_columns) {
  key_columns <- intersect(key_columns, names(.data))
  if (!length(key_columns)) {
    return(character())
  }

  other_columns <- setdiff(names(.data), key_columns)
  if (!length(other_columns)) {
    return(character())
  }

  n_key <- .data[key_columns] |>
    dplyr::distinct() |>
    nrow()
  keep <- vapply(
    other_columns,
    function(column_name) {
      .data[c(key_columns, column_name)] |>
        dplyr::distinct() |>
        nrow() == n_key
    },
    logical(1)
  )

  other_columns[keep]
}

#' Validate data parameters
#'
#' Given a data frame of Curated Atlas metadata obtained from [get_metadata()],
#' returns a list of parameters being validated.
#' @param data A data frame containing, at minimum, `cell_id`, `file_id_cellNexus_single_cell`
#'   and/or `file_id_cellNexus_pseudobulk`, and `atlas_id` column, which correspond to a single cell ID,
#'   file subdivision for internal use for single_cell and/or pseudobulk level, and
#'   atlas name in format (e.g cellxgene_2024/0.1.0) for internal use.
#'   They can be obtained from the [get_metadata()] function.
#'   Use `get_atlas_versions()` to download atlas versions data frame.
#' @param assays A character vector specifying the desired assay(s) to be requested.
#'   Valid elements include "counts", "cpm", "rank", and "sct" for single-cell analyses, or
#'   "counts" for pseudobulk analyses.
#'   The default setting retrieves only the counts assay.
#'   If your analysis involves a smaller set of genes, consider using the "cpm" assay.
#'   The "rank" assay is suited for signature calculations across millions of cells.
#' @param cell_aggregation A character vector that specifies which cell aggregation strategy
#' should be applied. This will create  a corresponding subdirectory in the atlas cache.
#' Choose one of the following: single_cell, pseudobulk
#' @param cache_directory An optional character vector of length one. If
#'   provided, it should indicate a local file path where any remotely accessed
#'   files should be copied.
#' @param repository A character vector of length one. If provided, it should be
#'   an HTTP URL pointing to the location where the single cell data is stored.
#' @param features An optional character vector of features (ie genes) to return
#'   the counts for. By default counts for all features will be returned.
#' @return A list containing validated parameters including data, repository, assays,
#'   cache_directory, features, cell_aggregation, and atlas_name.
#' @importFrom dplyr pull distinct collect
#' @importFrom purrr map
#' @importFrom checkmate assert check_true
#' @importFrom cli cli_alert_info cli_abort
#' @importFrom rlang .data
#' @references Shen, M., Y. Gao, N. Liu, D. Bhuva, M. Milton, J. Henao,
#'   J. Andrews, E. Yang, C. Zhan, N. Liu, S. Si, J. W. Hutchison,
#'   M. H. Shakeel, M. Morgan, A. T. Papenfuss, J. Iskander, J. M. Polo,
#'   and S. Mangiola. "cellNexus: Quality control, annotation, aggregation
#'   and analytical layers for the Human Cell Atlas data." bioRxiv (2026).
#'   doi:10.64898/2026.04.14.718336.
#' @source [Shen et al.,2026](https://www.biorxiv.org/content/10.64898/2026.04.14.718336v3)
#' @keywords internal
#' @noRd
validate_data <- function(
  data,
  assays = "counts",
  cell_aggregation,
  cache_directory = get_default_cache_dir(),
  repository = COUNTS_URL,
  features = NULL
) {
  # Parameter validation
  if (!all(assays %in% names(assay_map))) {
    cli_abort('assays must be a character vector containing counts and/or "cpm" and/or "rank" and/or "sct"')
  }
  assert(
    check_true(!anyDuplicated(assays)),
    check_true(inherits(cache_directory, "character")),
    check_true(is.null(repository) || is.character(repository)),
    check_true(is.null(features) || is.character(features))
  )

  # Data parameter validation (last, because it's slower)
  ## Evaluate the promise now so that we get a sensible error message
  force(data)
  ## We have to convert to an in-memory table here, or some of the dplyr
  ## operations will fail when passed a database connection
  cli_alert_info("Realising metadata.")
  raw_data <- collect(data)
  atlas_name <- raw_data |>
    distinct(.data$atlas_id) |>
    pull(.data$atlas_id)
  versioned_cache_directory <- file.path(cache_directory, atlas_name, cell_aggregation)

  versioned_cache_directory |>
    map(function(directory_path) {
      dir.create(
        directory_path,
        showWarnings = FALSE,
        recursive = TRUE
      )
    })

  list(
    data = data,
    repository = repository,
    assays = assays,
    cache_directory = versioned_cache_directory,
    features = features,
    cell_aggregation = cell_aggregation,
    atlas_name = atlas_name
  )
}

#' Converts a data frame into a Summarized Experiment
#'
#' This function converts a given data frame into a Summarized Experiment object,
#' allowing for handling of single-cell or pseudobulk data based on specified experiment
#' type. It requires specific columns for the data frame based on the type of
#' experiment data being processed.
#'
#' @param i Suffix to be added to the column names, to make them unique
#' @param df The data frame to be converted
#' @param dir_prefix The path to the single cell experiment, minus the final
#'   segment
#' @param features The list of genes/rows of interest
#' @param grouping_column A character vector of metadata column for grouping
#' @param metacell_column A character vector of metacell column (e.g. "metacell_2", "metacell_4") from metadata.
#' @param dropped_counter An optional environment with integer fields `n_dropped`,
#'   `n_files_affected`, and a character field `sample_ids`. When provided, missing
#'   cells are tallied into the environment in addition to the per-file warning,
#'   allowing the caller to emit a single consolidated summary after all files are
#'   read. If \code{NULL} (the default), only the per-file warning is issued.
#' @return A `SummarizedExperiment` object
#' @importFrom dplyr mutate filter select left_join distinct any_of all_of contains matches
#' @importFrom SummarizedExperiment colData<-
#' @importFrom tibble column_to_rownames
#' @importFrom utils head
#' @importFrom cli cli_alert_warning cli_abort
#' @importFrom glue glue
#' @importFrom zellkonverter readH5AD
#' @keywords internal
#' @noRd
group_to_data_container <- function(i, df, dir_prefix, features, grouping_column,
                                    metacell_column = NULL,
                                    dropped_counter = NULL) {
  experiment_path <- file.path(dir_prefix, df[[grouping_column]][1])

  if (!file.exists(experiment_path)) {
    cli_abort(paste0(
      "Your cache does not contain the file {experiment_path} you attempted",
      " to query. Please provide the repository parameter so that files can",
      " be synchronised from the internet"
    ))
  }

  experiment <- zellkonverter::readH5AD(experiment_path, reader = "R", use_hdf5 = TRUE)

  # Fix for https://github.com/tidyverse/dplyr/issues/6746
  force(i)

  if (grouping_column == "file_id_cellNexus_single_cell") {
    # Process specific to SCE
    cells <- colnames(experiment) |>
      intersect(df$cell_id)

    if (length(cells) < nrow(df)) {
      cli_alert_warning(paste(
        "The number of cells in the SingleCellExperiment will be less than the number",
        "of cells you have selected from the metadata.",
        "Are cell IDs duplicated? Or, do cell IDs correspond to the counts file?"
      ))
      if (!is.null(dropped_counter)) {
        n_missing <- nrow(df) - length(cells)
        dropped_counter$n_dropped <- dropped_counter$n_dropped + n_missing
        dropped_counter$n_files_affected <- dropped_counter$n_files_affected + 1L
        if ("sample_id" %in% names(df)) {
          affected <- unique(df$sample_id[!df$cell_id %in% cells])
          dropped_counter$sample_ids <- unique(c(dropped_counter$sample_ids, affected))
        }
      }
      df <- filter(df, .data$cell_id %in% cells)
    } else if (length(cells) > nrow(df)) {
      cli_abort("This should never happen")
    }

    new_coldata <- df |>
      mutate(original_cell_ = as.character(.data$cell_id), cell_id = glue("{cell_id}_{i}")) |>
      column_to_rownames("cell_id") |>
      as("DataFrame")

    experiment <- `if`(
      is.null(features),
      experiment[, new_coldata$original_cell_],
      {
        # Optionally subset the genes
        genes <- rownames(experiment) |>
          intersect(features)
        experiment[genes, new_coldata$original_cell_]
      }
    ) |>
      `colnames<-`(new_coldata$cell_id) |>
      `colData<-`(value = new_coldata)
  } else if (grouping_column == "file_id_cellNexus_pseudobulk") {
    # Process specific to Pseudobulk
    # remove cell-level annotations
    cell_level_anno <- c(
      "cell_id", "cell_type", "file_id_cellNexus_single_cell",
      "cell_type_ontology_term_id",
      "observation_joinid", "ensemble_joinid", "scaled_nCount_RNA",
      "nFeature_expressed_in_sample", "nCount_RNA", "data_driven_ensemble", "cell_type_unified",
      "empty_droplet", "observation_originalid", "alive", "scDblFinder.class", "is_immune"
    )

    filtered_df <- df |>
      select(-dplyr::all_of(intersect(names(df), cell_level_anno))) |>
      # Remove metacell and single-cell level annotations in pseudobulk
      dplyr::select(
        -dplyr::contains("metacell"),
        -dplyr::matches("azimuth|monaco|blueprint|subsets_|high_"),
        -dplyr::matches("raw_|nnz|n_meatured_vars|soma_")
      )

    pseudobulk_columns <- get_specific_annotation_columns(
      filtered_df,
      key_columns = c("sample_id", "cell_type_unified_ensemble")
    )

    new_coldata <- df |>
      select(all_of(unique(c("sample_id", "cell_type_unified_ensemble", pseudobulk_columns)))) |>
      distinct() |>
      mutate(
        sample_identifier = paste(
          .data$sample_id,
          .data$cell_type_unified_ensemble,
          sep = "___"
        ),
        original_sample_id = .data$sample_identifier
      ) |>
      column_to_rownames("original_sample_id")

    experiment <- `if`(
      is.null(features),
      experiment[, new_coldata$sample_identifier],
      {
        genes <- rownames(experiment) |>
          intersect(features)
        experiment[genes, new_coldata$sample_identifier]
      }
    ) |>
      `colnames<-`(new_coldata$sample_identifier) |>
      `colData<-`(value = DataFrame(new_coldata))

    # Force renaming type class to save `SummarizedExperiment` object
    experiment <- experiment |>
      as("SingleCellExperiment")
  } else if (grouping_column == "file_id_cellNexus_metacell") {
    # Select relevant annotations to remove single-cell level annotations
    annotations <- metacell_column |>
      c(
        "dataset_id", "sample_id", "assay", "assay_ontology_term_id",
        "development_stage", "development_stage_ontology_term_id", "disease", "disease_ontology_term_id",
        "donor_id", "experiment___", "explorer_url", "feature_count", "is_primary_data",
        "organism", "organism_ontology_term_id", "published_at", "raw_data_location",
        "revised_at", "sample_heuristic", "schema_version", "self_reported_ethnicity",
        "self_reported_ethnicity_ontology_term_id", "sex", "sex_ontology_term_id", "tissue",
        "tissue_ontology_term_id", "tissue_type", "title", "tombstone", "url", "age_days",
        "tissue_groups", "atlas_id", "sample_chunk", "file_id_cellNexus_single_cell",
        "file_id_cellNexus_metacell", "dir_prefix"
      )

    mapping_tbl <- as.data.frame(SummarizedExperiment::colData(experiment)) |>
      select(all_of(c("sample_id", metacell_column, "metacell_id")))

    new_coldata <- df |>
      dplyr::left_join(
        mapping_tbl,
        by = c("sample_id", metacell_column)
      ) |>
      select(any_of(annotations), all_of("metacell_id")) |>
      distinct() |>
      mutate(
        original_metacell_id = .data$metacell_id,
        metacell_identifier = paste(.data$metacell_id, i, sep = "_")
      ) |>
      column_to_rownames("metacell_identifier")

    experiment <- `if`(
      is.null(features),
      experiment[, new_coldata$original_metacell_id],
      {
        # Optionally subset the genes
        genes <- rownames(experiment) |>
          intersect(features)
        experiment[genes, new_coldata$original_metacell_id]
      }
    ) |>
      `colnames<-`(new_coldata$original_metacell_id) |>
      `colData<-`(value = DataFrame(new_coldata))
  }

  experiment
}

#' Synchronise one or more remote assay files to a local cache
#'
#' Convenience wrapper that calls `build_assay_file_list()` to construct the
#' set of remote URLs and local destinations, then passes the result to
#' `sync_all_assay_files()` to perform the download. Use this for simple
#' single-call download scenarios; for batched parallel downloads across many
#' atlases, call `build_assay_file_list()` and `sync_all_assay_files()`
#' directly.
#'
#' @param url A parsed URL object (from [httr::parse_url()]). Defaults to the
#'   package-level `COUNTS_URL`.
#' @param atlas_name A character vector. Atlas identifier(s) used as path
#'   components (e.g. `"cellxgene_2024/0.1.0"`). Use `get_atlas_versions()` to
#'   download atlas versions data frame.
#' @param cell_aggregation A character vector. Cell aggregation level(s). Pass
#'   `""` for unaggregated (single-cell) data.
#' @param cache_dir A character vector of length one. Root local directory
#'   under which files are cached.
#' @param subdirs A character vector. Assay subdirectory name(s) (e.g.
#'   `"counts"`, `"cpm"`).
#' @param files A character vector. One or more `file_id_cellNexus_single_cell`
#'   values (H5AD file names) to download.
#' @return Invisibly, a character vector of local file paths for all requested
#'   files (whether newly downloaded or already cached).
#' @importFrom httr parse_url
#' @keywords internal
#' @noRd
sync_assay_files <- function(
  url = parse_url(COUNTS_URL),
  atlas_name,
  cell_aggregation,
  cache_dir,
  subdirs,
  files
) {
  build_assay_file_list(
    url = url,
    atlas_name = atlas_name,
    cell_aggregation = cell_aggregation,
    cache_dir = cache_dir,
    subdirs = subdirs,
    files = files
  ) |>
    sync_all_assay_files()
}

#' Build a data frame of remote URLs and local output paths for assay files
#'
#' Constructs all combinations of atlas, cell aggregation, assay subdirectory,
#' and file, returning a data frame with the remote URL and local destination
#' path for each file. No downloading is performed; this is used to collect
#' all targets before passing them to `sync_all_assay_files()` for a single
#' parallel download batch.
#'
#' @param url A parsed URL object (from [httr::parse_url()]). The base HTTP
#'   URL of the remote file store.
#' @param atlas_name A character vector. One or more atlas identifiers (e.g.
#'   `"cellxgene_2024/0.1.0"`), used as path components in both the remote URL
#'   and the local cache path.
#' @param cell_aggregation A character vector. Cell aggregation level(s) used
#'   as a path component. Pass `""` for unaggregated (single-cell) data.
#' @param cache_dir A character vector of length one. Root local directory
#'   under which files are cached.
#' @param subdirs A character vector. Subdirectory name(s) corresponding to
#'   assay types (e.g. `"counts"`, `"cpm"`).
#' @param files A character vector. One or more
#'   `file_id_cellNexus_single_cell` values (H5AD file names) to include.
#' @return A data frame with columns:
#'   \describe{
#'     \item{`full_url`}{Character. The fully-qualified remote URL for each
#'       file.}
#'     \item{`output_file`}{Character. The absolute local file path where
#'       the file should be saved.}
#'   }
#' @importFrom purrr map_chr
#' @importFrom httr modify_url
#' @importFrom rlang .data
#' @keywords internal
#' @noRd
build_assay_file_list <- function(
  url,
  atlas_name,
  cell_aggregation,
  cache_dir,
  subdirs,
  files
) {
  # Find every combination of file name, sample id, and assay, since each
  # will be a separate file we need to download
  grid <- expand.grid(
    atlas_name = atlas_name,
    cell_aggregation = cell_aggregation,
    sample_id = files,
    subdir = subdirs,
    stringsAsFactors = FALSE
  )
  # Build full remote URLs: construct the path, format into the base URL, then
  # collapse any double-slashes (Nectar cloud is strict about these).
  # Path to the file of interest from the root path. We use "/"
  # since URLs must use these regardless of OS
  raw_paths <- paste(
    url$path, grid$atlas_name, grid$cell_aggregation, grid$subdir, grid$sample_id,
    sep = "/"
  )
  full_urls <- gsub(
    "(?<!:)/{2,}", "/",
    map_chr(raw_paths, ~ modify_url(url, path = .x)),
    perl = TRUE
  )
  data.frame(
    full_url = full_urls,
    output_file = file.path(cache_dir, grid$atlas_name, grid$cell_aggregation, grid$subdir, grid$sample_id),
    stringsAsFactors = FALSE
  )
}

#' Download all assay files in parallel
#'
#' Collects all file URLs and downloads them in a single parallel batch.
#' @param file_list A data frame with full_url and output_file columns
#' @importFrom cli cli_alert_info
#' @noRd
sync_all_assay_files <- function(file_list) {
  if (nrow(file_list) == 0) {
    return(invisible(character(0)))
  }

  # Filter to only files that don't already exist
  to_download <- !file.exists(file_list$output_file)

  if (sum(to_download) > 0) {
    report_file_sizes(file_list$full_url[to_download])
    sync_remote_files(
      file_list$full_url[to_download],
      file_list$output_file[to_download],
      progress = TRUE
    )
  }

  invisible(file_list$output_file)
}

#' Checks whether genes in a list of SummarizedExperiment objects overlap
#' @param obj_list A list of SummarizedExperiment objects
#' @return A character vector of genes intersection across objects
#' @importFrom purrr map reduce
#' @importFrom cli cli_alert_warning
#' @keywords internal
#' @noRd
check_gene_overlap <- function(obj_list) {
  gene_lists <- map(obj_list, rownames)
  common_genes <- reduce(gene_lists, intersect)
  if (any(lengths(gene_lists) != length(common_genes))) {
    cli_alert_warning(
      paste(
        "cellNexus says: Not all genes completely overlap across the provided objects.",
        "Counts are generated by genes intersection."
      )
    )
  }
  common_genes
}
