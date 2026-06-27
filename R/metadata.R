# Functions that relate to the harmonised metadata database

#' Environment that we use to cache the DuckDB connections
#' @keywords internal
#' @noRd
cache <- rlang::env(
  metadata_table = rlang::env()
)

#' Returns the URLs for all metadata files
#' @param databases A character vector specifying the names of the metadata files.
#'   Download the specific metadata by defining the metadata version.
#' @export
#' @return A character vector of URLs to parquet files to download
#' @examples
#' get_metadata_url("cellnexus_metadata.2.3.0.parquet")
#' @references Shen, M., Y. Gao, N. Liu, D. Bhuva, M. Milton, J. Henao,
#'   J. Andrews, E. Yang, C. Zhan, N. Liu, S. Si, J. W. Hutchison,
#'   M. H. Shakeel, M. Morgan, A. T. Papenfuss, J. Iskander, J. M. Polo,
#'   and S. Mangiola. "cellNexus: Quality control, annotation, aggregation
#'   and analytical layers for the Human Cell Atlas data." bioRxiv (2026).
#'   doi:10.64898/2026.04.14.718336.
#' @source [Shen et al.,2026](https://www.biorxiv.org/content/10.64898/2026.04.14.718336v3)
get_metadata_url <- function(databases = c(
                               "cellnexus_metadata.2.3.0.parquet",
                               "census_cell_metadata.2.3.0.parquet"
                             )) {
  glue::glue(
    "https://object-store.rc.nectar.org.au/v1/AUTH_06d6e008e3e642da99d806ba3ea629c5/cellNexus-metadata/{databases}"
  )
}

#' URL pointing to the sample metadata file, which is smaller and for test,
#' demonstration, and vignette purposes only
#' @export
#' @return Character scalar consisting of the URL/URLs
#' @examples
#' get_metadata(cloud_metadata = SAMPLE_DATABASE_URL["cellnexus"], cache_directory = tempdir())
#' @references Shen, M., Y. Gao, N. Liu, D. Bhuva, M. Milton, J. Henao,
#'   J. Andrews, E. Yang, C. Zhan, N. Liu, S. Si, J. W. Hutchison,
#'   M. H. Shakeel, M. Morgan, A. T. Papenfuss, J. Iskander, J. M. Polo,
#'   and S. Mangiola. "cellNexus: Quality control, annotation, aggregation
#'   and analytical layers for the Human Cell Atlas data." bioRxiv (2026).
#'   doi:10.64898/2026.04.14.718336.
#' @source [Shen et al.,2026](https://www.biorxiv.org/content/10.64898/2026.04.14.718336v3)
SAMPLE_DATABASE_URL <- c(
  cellnexus = paste0(
    "https://object-store.rc.nectar.org.au/v1/AUTH_06d6e008e3e642da99d806ba3ea629c5/",
    "cellNexus-metadata/cellnexus_sample_metadata.2.3.0.parquet"
  ),
  census = paste0(
    "https://object-store.rc.nectar.org.au/v1/AUTH_06d6e008e3e642da99d806ba3ea629c5/",
    "cellNexus-metadata/census_sample_metadata.2.3.0.parquet"
  )
)

#' Gets the CellNexus metadata as a data frame.
#'
#' Downloads a parquet database of the Human Cell Atlas metadata to a local
#' cache, and then opens it as a data frame. It can then be filtered and passed
#' into [get_single_cell_experiment()] to obtain a
#' [`SingleCellExperiment::SingleCellExperiment-class`]
#'
#' @param cloud_metadata Optional character vector of any length. HTTP URL/URLs pointing
#'   to the name and location of parquet database/databases. By default, it points to
#'   cellNexus ARDC Nectar Research Cloud. Assign `NULL` to query local_metadata only
#'   if exists.
#' @param local_metadata Optional character vector of any length representing the local
#'   path of parquet database(s).
#' @param cache_directory Optional character vector of length 1. A file path on
#'   your local system to a directory (not a file) that will be used to store metadata.
#' @param use_cache Optional logical scalar. If `TRUE` (the default), and this
#'   function has been called before with the same parameters, then a cached
#'   reference to the table will be returned. If `FALSE`, a new connection will
#'   be created no matter what.
#' @return A lazy data.frame subclass containing the metadata. You can interact
#'   with this object using most standard dplyr functions. For string matching,
#'   it is recommended that you use `stringr::str_like` to filter character
#'   columns, as `stringr::str_match` will not work.
#' @export
#' @examples
#' library(dplyr)
#' # For fast build purpose only, you do not need to specify anything in cloud_metadata.
#' filtered_metadata <- get_metadata(cloud_metadata = SAMPLE_DATABASE_URL) |>
#'   filter(
#'     self_reported_ethnicity == "African" &
#'       assay %LIKE% "%10x%" &
#'       tissue == "lung parenchyma" &
#'       cell_type %LIKE% "%CD4%"
#'   )
#'
#' @importFrom DBI dbConnect
#' @importFrom duckdb duckdb
#' @importFrom dplyr tbl
#' @importFrom httr progress
#' @importFrom cli cli_alert_info hash_sha256
#' @importFrom glue glue glue_sql
#' @importFrom purrr walk
#' @importFrom dbplyr sql
#'
#' @details
#'
#' The metadata was collected from the Bioconductor package `cellxgenedp`.
#' `vignette("using_cellxgenedp", package="cellxgenedp")` provides an overview of the columns in the
#' metadata. The data for which the column `organism_name` included "Homo
#' sapiens" was collected collected from `cellxgenedp`.
#'
#' The columns `dataset_id` and `file_id_cellNexus_single_cell` link the datasets explorable through
#' `cellNexus` and `cellxgenedp`to the CELLxGENE portal.
#'
#' Our representation, harmonises the metadata at dataset, sample and cell
#' levels, in a unique coherent database table.
#'
#' Field definitions for the CELLxGENE schema follow the
#' [CELLxGENE schema 5.1.0](https://github.com/chanzuckerberg/single-cell-curation/blob/main/schema/5.1.0/schema.md).
#'
#' Through harmonisation and curation we introduced custom columns not present
#' in the original CELLxGENE metadata:
#'
#' `cell_count`: Number of cells in a dataset.
#' `feature_count`: Number of genes in a dataset.
#' `age_days`: Donor age in days.
#' `tissue_groups`: Coarse tissue grouping for analysis.
#' `empty_droplet`: Whether a cell is called an empty droplet from expressed-gene count per sample (default threshold 200; targeted panels may differ).
#' `alive`: Whether a cell passes viability / mitochondrial QC.
#' `scDblFinder.class`: Doublet, singlet, or unknown (`scDblFinder` default parameters).
#' `cell_type_unified_ensemble`: Consensus immune identity from Azimuth and SingleR (Blueprint, Monaco).
#' `cell_annotation_azimuth_l2`: Azimuth cell annotation.
#' `cell_annotation_blueprint_singler`: SingleR annotation (Blueprint).
#' `cell_annotation_blueprint_monaco`: SingleR annotation (Monaco).
#' `is_immune`: Whether a cell is an immune cell.
#' `sample_heuristic`: Internal sample subdivision helper.
#' `file_id_cellNexus_single_cell`: Internal file id for single-cell layers.
#' `file_id_cellNexus_pseudobulk`: Internal file id for pseudobulk layers.
#' `sample_id`: Harmonised sample identifier.
#' `nCount_RNA`: Total RNA counts per cell (sample-aware).
#' `nFeature_expressed_in_sample`: Number of expressed features per cell.
#' `ethnicity_flagging_score`: Supporting score for ethnicity imputation.
#' `low_confidence_ethnicity`: Supporting flag for low-confidence ethnicity calls.
#' `.aggregated_cells`: Post-QC cells combined into each pseudobulk sample.
#' `imputed_ethnicity`: Imputed ethnicity label.
#' `atlas_id`: cellNexus atlas release identifier (internal use).
#'
#' For all fields definitions, please refer to our [documentation site](https://cellnexus.org/)
#'
#' **Possible cache path issues**
#'
#' If your default R cache path includes non-standard characters (e.g. dash
#' because of your user or organisation name), the following error can occur.
#'
#' ```
#' Error in `db_query_fields.DBIConnection()`: ! Can't query fields. Caused by
#' error: ! Parser Error: syntax error at or near "/" LINE 2: FROM
#' /Users/bob/Library/Caches...
#' ```
#'
#' The solution is to choose a different cache, for example
#' ```R
#' get_metadata(cache_directory = path.expand('~'))
#' ```
#'
#' @references Shen, M., Y. Gao, N. Liu, D. Bhuva, M. Milton, J. Henao,
#'   J. Andrews, E. Yang, C. Zhan, N. Liu, S. Si, J. W. Hutchison,
#'   M. H. Shakeel, M. Morgan, A. T. Papenfuss, J. Iskander, J. M. Polo,
#'   and S. Mangiola. "cellNexus: Quality control, annotation, aggregation
#'   and analytical layers for the Human Cell Atlas data." bioRxiv (2026).
#'   doi:10.64898/2026.04.14.718336.
#' @source [Shen et al.,2026](https://www.biorxiv.org/content/10.64898/2026.04.14.718336v3)
get_metadata <- function(cloud_metadata = get_metadata_url("cellnexus_metadata.2.3.0.parquet"),
                         local_metadata = NULL,
                         cache_directory = get_default_cache_dir(),
                         use_cache = TRUE) {
  # Synchronize remote files using parallel downloads
  if (!is.null(cloud_metadata) && length(cloud_metadata) > 0) {
    output_paths <- file.path(cache_directory, basename(cloud_metadata))
    # Filter to only files that need downloading
    to_download <- !file.exists(output_paths)
    if (any(to_download)) {
      report_file_sizes(cloud_metadata[to_download])
      sync_remote_files(cloud_metadata[to_download],
        output_paths[to_download],
        progress = TRUE
      )
    }
  }

  if (is.null(cloud_metadata)) all_parquet <- c(local_metadata)
  if (!is.null(cloud_metadata)) {
    all_parquet <- c(
      file.path(
        cache_directory,
        cloud_metadata |>
          basename()
      ),
      local_metadata
    )
  }

  # We try to avoid re-reading a set of parquet files
  # that is identical to a previous set by hashing the file list
  hash <- all_parquet |>
    paste0(collapse = "") |>
    hash_sha256()
  cached_connection <- cache$metadata_table[[hash]]

  if (!is.null(cached_connection) && isTRUE(use_cache)) {
    # If the file list is identical, just re-use the database table
    cached_connection
  } else {
    table <- duckdb() |>
      dbConnect(drv = _, read_only = TRUE) |>
      duckdb_read_parquet(path = all_parquet)
    cache$metadata_table[[hash]] <- table
    table
  }
}

#' Retrieve cellNexus cell communication ligand–receptor strength as a data frame.
#'
#' Downloads a parquet database of the cell communication strength to a local
#' cache, and then opens it as a data frame. It can then be filtered.
#'
#' @param cloud_metadata Character vector of any length. HTTP URL/URLs pointing
#'   to the name and location of parquet database/databases. By default, it points to
#'   cell communication metadata in cellNexus ARDC Nectar Research Cloud.
#'   Assign `NULL` to query local_metadata only if exists.
#' @param local_metadata Optional character vector of any length representing the local
#'   path of parquet database(s).
#' @param cache_directory Optional character vector of length 1. A file path on
#'   your local system to a directory (not a file) that will be used to store
#'   `metadata.parquet`
#' @param use_cache Optional logical scalar. If `TRUE` (the default), and this
#'   function has been called before with the same parameters, then a cached
#'   reference to the table will be returned. If `FALSE`, a new connect138/4.7ion will
#'   be created no matter what.
#' @return A lazy data.frame subclass containing the metadata. You can interact
#'   with this object using most standard dplyr functions. For string matching,
#'   it is recommended that you use `stringr::str_like` to filter character
#'   columns, as `stringr::str_match` will not work.
#' @details
#' The returned table integrates three levels of cell communication
#'   inference from `CellChat`, for each sample:
#'   (i) ligand–receptor–level communication (\code{lr_prob}, \code{lr_pval}),
#'   (ii) pathway-level aggregated signaling (\code{pathway_prob}, \code{pathway_pval}),
#'   (iii) cell-pair–level summaries of communication breadth
#'   (\code{interaction_count} - number of significant LR interactions) and
#'   intensity (\code{interaction_weight} - overall communication strength).
#'
#'   Together, these metrics allow simultaneous assessment of signaling specificity,
#'   pathway dominance, and global communication structure between cell populations.
#' @examples
#' # For fast build purpose only, you do not need to specify anything in the function.
#' communication_meta <- get_cell_communication_strength(
#'   cloud_metadata = get_metadata_url(
#'     "cellNexus_lr_signaling_pathway_strength_DEMO.parquet"
#'   )
#' )
#' @export
get_cell_communication_strength <- function(
  cloud_metadata = get_metadata_url("cellNexus_lr_signaling_pathway_strength.parquet"),
  local_metadata = NULL,
  cache_directory = get_default_cache_dir(),
  use_cache = TRUE
) {
  get_metadata(cloud_metadata, local_metadata, cache_directory, use_cache)
}

#' Returns the atlas version changelog as a tibble
#'
#' Downloads the `atlas_versions.parquet` registry from the cellNexus metadata
#' store, caches it locally, and returns it as an in-memory tibble. Each row
#' describes one atlas data release and its relationship to a CellxGene Census
#' snapshot.
#'
#' The `atlas_id` column in this table corresponds directly to the `atlas_id`
#' column returned by [get_metadata()], so you can join them to find which
#' Census snapshot any cell in your query came from.
#'
#' @param cache Optional character scalar. A local directory used to
#'   cache the downloaded parquet file. Defaults to a temporary directory to
#'   separate from the main cache directory.
#' @return A tibble with columns:
#'   \describe{
#'     \item{atlas_id}{Atlas version identifier, e.g. `"cellxgene_2024/0.1.0"`.
#'       Matches the `atlas_id` column in [get_metadata()].}
#'     \item{census_version}{The CellxGene Census snapshot this atlas was built
#'       from, e.g. `"01-07-2024"`.}
#'     \item{change_type}{One of `"initial"`, `"patch"`, `"minor"`, or
#'       `"major"`. See `ATLAS_VERSIONS.md` for the conventions standards.}
#'     \item{description}{Summary text of what changed in this release.}
#'     \item{modified_at}{Modification date as a character scalar (`"YYYY-MM-DD"`).
#'       By default use `Sys.Date()`}
#'   }
#' @seealso
#' \itemize{
#'   \item CellxGene Census data releases (LTS):
#'   \url{https://chanzuckerberg.github.io/cellxgene-census/cellxgene_census_docsite_data_release_info.html}
#' }
#' @export
#' @examples
#' get_atlas_versions()
#' @references Shen, M., Y. Gao, N. Liu, D. Bhuva, M. Milton, J. Henao,
#'   J. Andrews, E. Yang, C. Zhan, N. Liu, S. Si, J. W. Hutchison,
#'   M. H. Shakeel, M. Morgan, A. T. Papenfuss, J. Iskander, J. M. Polo,
#'   and S. Mangiola. "cellNexus: Quality control, annotation, aggregation
#'   and analytical layers for the Human Cell Atlas data." bioRxiv (2026).
#'   doi:10.64898/2026.04.14.718336.
#' @source [Shen et al.,2026](https://www.biorxiv.org/content/10.64898/2026.04.14.718336v3)
get_atlas_versions <- function(cache = tempdir()) {
  registry_url <- get_metadata_url("atlas_versions.parquet")
  local_path <- file.path(cache, "atlas_versions.parquet")
  sync_remote_file(registry_url,
    local_path,
    overwrite = TRUE
  )
  arrow::read_parquet(local_path)
}

#' @rdname get_census_metadata
#' @param tbl Deprecated. Previously a `tbl_sql` object to join against.
#' @param ... Deprecated arguments, ignored.
#' @importFrom cli cli_alert_warning
#' @keywords internal
#' @noRd
join_census_table <- function(tbl, ...) {
  cli_alert_warning(paste(
    "{.fun join_census_table} is deprecated.",
    "Use {.fun get_census_metadata} instead to retrieve a Census data frame",
    "and join it to your metadata manually."
  ))
  get_census_metadata(...)
}

#' Retrieve cell-level metadata from CZ CELLxGENE Census
#'
#' Fetches cell-level metadata for human primary-data cells directly from the
#' CZ CELLxGENE Census using the Long-Term Stable (LTS) release. The result is
#' a standard Arrow Table that can be registered at the same connection 
#' as `get_metadata()`, and joined via shared keys such as 
#' `observation_joinid` and `dataset_id`.
#'
#' @param census_version A character string specifying the Census LTS version
#'   to query. For available LTS versions see the
#'   [Census release changelog](https://chanzuckerberg.github.io/cellxgene-census/cellxgene_census_docsite_data_release_info.html).
#'   To find the LTS version associated with a specific cellNexus atlas, use
#'   [get_atlas_versions()].
#' @return A standard Arrow Table of human primary-data cell metadata from the Census,
#'   materialized from the lazy SOMA iterator.
#' @importFrom cli cli_abort cli_alert_info
#' @keywords internal
#' @noRd
get_census_metadata <- function(census_version) {
  if (!requireNamespace("cellxgene.census", quietly = TRUE)) {
    cli_abort(paste(
      "The {.pkg cellxgene.census} package is required.",
      "Install it with:",
      "{.code install.packages('cellxgene.census',",
      "repos = c('https://chanzuckerberg.r-universe.dev',",
      "'https://cloud.r-project.org'))}"
    ))
  }
  
  cli_alert_info("Opening Census version {census_version}.")
  census <- cellxgene.census::open_soma(census_version = census_version)
  on.exit(census$close(), add = TRUE)
  
  metadata <- census$get("census_data")$get("homo_sapiens")$get("obs")
  
  cli_alert_info("Reading Census obs table.")
  census_metadata <- metadata$read(
    value_filter = "is_primary_data == 'TRUE'"
  )$concat()
}

#' Retrieve Metadata from CELLxGENE Data Portal
#'
#' @description
#' Queries the CELLxGENE Data Portal database and returns metadata at the
#' specified level of granularity. Requires the \pkg{cellxgenedp} package.
#'
#' @param level Character string specifying the metadata level to retrieve.
#' @param overwrite Additional arguments passed to \code{\link[cellxgenedp]{db}},
#'   such as \code{overwrite = FALSE} to use the cached database.
#'
#' @return A \code{\link[tibble]{tibble}} containing metadata from the
#'   CELLxGENE Data Portal at the requested level. Columns vary by level:
#'   \describe{
#'     \item{\code{"dataset"}}{Includes fields such as dataset ID, title,
#'       organism, tissue, assay, disease, and cell count.}
#'     \item{\code{"collection"}}{Includes fields such as collection ID, name,
#'       description, and publisher metadata.}
#'     \item{\code{"file"}}{Includes fields such as file ID, filename, filetype,
#'       and download URL.}
#'   }
#'
#' @seealso
#' \itemize{
#'   \item \code{\link[cellxgenedp]{datasets}} for the underlying datasets query
#'   \item \code{\link[cellxgenedp]{collections}} for the underlying collections query
#'   \item \code{\link[cellxgenedp]{files}} for the underlying files query
#'   \item \href{https://chanzuckerberg.github.io/cellxgenedp/}{cellxgenedp documentation}
#' }
#'
#' @importFrom cli cli_abort
#' @noRd
#' @keywords internal
get_cellxgene_metadata <- function(level = c("dataset", "collection", "file"),
                                   overwrite = FALSE) {
  if (!requireNamespace("cellxgenedp", quietly = TRUE)) {
    cli::cli_abort(c(
      "The {.pkg cellxgenedp} package is required.",
      "i" = "Install it with: {.code BiocManager::install('cellxgenedp')}"
    ))
  }
  level <- match.arg(level)
  db <- cellxgenedp::db(overwrite)
  switch(level,
         collection = cellxgenedp::collections(db),
         dataset    = cellxgenedp::datasets(db),
         file       = cellxgenedp::files(db)
  )
}
