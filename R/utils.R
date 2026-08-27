# Utility scripts that are used internally by the package at runtime

#' Gets the file size of a number of remote files
#' @param urls A character vector containing URLs
#' @return The file size of each of the files pointed to by the provided URL,
#' in gigabytes, as double vector
#' @importFrom curl multi_run new_pool curl_fetch_memory parse_headers_list
#' @importFrom purrr map_dbl
#' @keywords internal
#' @noRd
url_file_size <- function(urls) {
  if (length(urls) == 0) {
    return(numeric(0))
  }

  # Use curl for parallel HEAD requests
  env <- new.env(parent = emptyenv())
  env$sizes <- rep(NA_real_, length(urls))
  pool <- new_pool()

  for (i in seq_along(urls)) {
    curl::curl_fetch_multi(
      urls[i],
      done = function(res) {
        idx <- which(urls == res$url)
        if (length(idx) > 0) {
          headers <- parse_headers_list(res$headers)
          content_length <- headers[["content-length"]]
          if (!is.null(content_length)) {
            env$sizes[idx[1]] <- as.numeric(content_length) / 10^9
          }
        }
      },
      fail = function(msg) {},
      pool = pool,
      handle = curl::new_handle(nobody = TRUE)
    )
  }

  multi_run(pool = pool)
  env$sizes[is.na(env$sizes)] <- 0
  env$sizes
}

#' Fetches ETag (MD5) and Content-Length for remote files via one parallel HEAD
#' batch.  On OpenStack Swift the ETag is the object's MD5 hex digest.
#' Combining both headers in a single round-trip avoids a second batch when we
#' need to cross-check file size before computing local MD5.
#' @param urls A character vector of URLs
#' @return A data frame with columns \code{etag} (character, NA when absent)
#'   and \code{size_bytes} (numeric, NA when absent)
#' @importFrom curl multi_run new_pool curl_fetch_multi new_handle parse_headers_list
#' @keywords internal
#' @noRd
url_file_head_info <- function(urls) {
  if (length(urls) == 0) {
    return(data.frame(etag = character(0), size_bytes = numeric(0)))
  }

  env <- new.env(parent = emptyenv())
  env$etags <- rep(NA_character_, length(urls))
  env$sizes <- rep(NA_real_, length(urls))
  pool <- new_pool()

  for (i in seq_along(urls)) {
    curl::curl_fetch_multi(
      urls[i],
      done = function(res) {
        idx <- which(urls == res$url)
        # Only capture headers from successful responses.  A 404 (or any
        # non-2xx) still triggers done(), not fail(), but its Content-Length
        # describes the error page, not the actual object.  Trusting that
        # length would incorrectly flag locally-cached files as corrupt.
        if (length(idx) > 0 && res$status_code >= 200 && res$status_code < 300) {
          h <- parse_headers_list(res$headers)
          etag <- h[["etag"]]
          if (!is.null(etag)) {
            env$etags[idx[1]] <- gsub('^"(.*)"$', "\\1", etag)
          }
          cl <- h[["content-length"]]
          if (!is.null(cl)) {
            env$sizes[idx[1]] <- as.numeric(cl)
          }
        }
      },
      fail = function(msg) {},
      pool = pool,
      handle = curl::new_handle(nobody = TRUE)
    )
  }

  multi_run(pool = pool)
  data.frame(etag = env$etags, size_bytes = env$sizes)
}

#' Kept for backward-compatibility; delegates to url_file_head_info
#' @keywords internal
#' @noRd
url_file_etag <- function(urls) {
  url_file_head_info(urls)$etag
}

#' Verifies a cached file's integrity against the remote object.
#'
#' Two-stage check to avoid reading large files unnecessarily:
#' 1. Size check (instant): compare \code{file.size()} with Content-Length.
#'    A mismatch means the file was only partially downloaded — no MD5 needed.
#' 2. MD5 check (reads the file): compare \code{tools::md5sum()} with ETag.
#'    Only reached when the size is correct, guarding against silent disk
#'    corruption without penalising the common "correctly cached" path.
#'
#' Returns TRUE when the file is intact, or when neither Content-Length nor
#' ETag is available (servers that don't expose these headers are never
#' penalised).
#' @param url URL of the remote file
#' @param local_file Path to the locally cached file
#' @return Logical scalar
#' @importFrom tools md5sum
#' @keywords internal
#' @noRd
check_file_integrity <- function(url, local_file) {
  if (!isTRUE(getOption("cellNexus.check_cache_integrity", TRUE))) {
    return(TRUE)
  }
  info <- url_file_head_info(url)

  # Stage 1: size check (no file I/O)
  # A partial download is always shorter than the complete object.
  if (!is.na(info$size_bytes)) {
    if (file.size(local_file) != info$size_bytes) {
      return(FALSE)
    }
  }

  # Stage 2: MD5 check (reads the file)
  # Only reached when the sizes match.  Catches rare silent corruption without
  # incurring full-file reads for the common "correctly downloaded" case.
  if (!is.na(info$etag)) {
    local_md5 <- unname(tools::md5sum(local_file))
    return(tolower(info$etag) == tolower(local_md5))
  }

  TRUE # Can't verify, assume OK
}

#' Prints a message indicating the size of a download
#' @param urls A character vector containing URLs
#' @importFrom cli cli_alert_info
#' @keywords internal
#' @noRd
#' @return `NULL`, invisibly
report_file_sizes <- function(urls) {
  total_size <- url_file_size(urls) |>
    sum() |>
    round(digits = 2)

  "Downloading {length(urls)} file{?s}, totalling {total_size} GB" |>
    cli_alert_info()

  invisible(NULL)
}

#' Returns the default cache directory with a version number
#'
#' @section Cache integrity checking:
#' By default, every file in the cache is verified against its remote ETag
#' (MD5) before being reused.  This catches partial downloads left by
#' interrupted sessions.  You should only disable the check when the cache
#' is known to be intact.
#' \preformatted{options(cellNexus.check_cache_integrity = FALSE)}
#'
#' To make this permanent, add the line to your \file{~/.Rprofile}.
#'
#' @export
#' @return A length one character vector.
#' @importFrom tools R_user_dir
#' @importFrom utils packageName
#' @examples
#' get_metadata(cloud_metadata = SAMPLE_DATABASE_URL, cache_directory = get_default_cache_dir())
#' @references Shen, M., Y. Gao, N. Liu, D. Bhuva, M. Milton, J. Henao,
#'   J. Andrews, E. Yang, C. Zhan, N. Liu, S. Si, J. W. Hutchison,
#'   M. H. Shakeel, M. Morgan, A. T. Papenfuss, J. Iskander, J. M. Polo,
#'   and S. Mangiola. "cellNexus: Quality control, annotation, aggregation
#'   and analytical layers for the Human Cell Atlas data." bioRxiv (2026).
#'   doi:10.64898/2026.04.14.718336.
#' @source [Shen et al.,2026](https://www.biorxiv.org/content/10.64898/2026.04.14.718336v3)
get_default_cache_dir <- function() {
  packageName() |>
    R_user_dir(
      "cache"
    ) |>
    normalizePath(mustWork = FALSE)
}

#' Synchronises a single remote file with a local path
#' @importFrom httr write_disk GET stop_for_status
#' @importFrom cli cli_abort cli_alert_info cli_alert_warning
#' @return `NULL`, invisibly
#' @keywords internal
#' @noRd
sync_remote_file <- function(full_url, output_file, overwrite = FALSE,
                             ignore_not_found = FALSE, ...) {
  if (isTRUE(overwrite) && file.exists(output_file)) {
    file.remove(output_file)
  }

  # If a cached copy exists, verify its MD5 against the remote ETag before
  # reusing it.  A mismatch indicates the file was only partially downloaded
  # (e.g. the R session or network was interrupted mid-transfer) and it must
  # be deleted so the download restarts cleanly.
  if (file.exists(output_file) &&
    !check_file_integrity(full_url, output_file)) {
    cli_alert_warning(
      "Cached file {.path {output_file}} failed MD5 integrity check (partial or corrupt download). Deleting and re-downloading."
    )
    file.remove(output_file)
  }

  if (!file.exists(output_file)) {
    output_dir <- dirname(output_file)
    dir.create(output_dir,
      recursive = TRUE,
      showWarnings = FALSE
    )
    cli_alert_info("Downloading {full_url} to {output_file}")

    tryCatch(
      GET(full_url, write_disk(output_file), ...) |>
        stop_for_status(),
      error = function(e) {
        # Clean up partial download regardless.
        if (file.exists(output_file)) file.remove(output_file)
        # For SCT assays the file may legitimately not exist (normalisation
        # failed for that sample).  When the caller opts in, treat HTTP 404 as
        # "file not available" rather than a hard error; the file is simply
        # absent from the cache and downstream logic handles it.
        if (ignore_not_found &&
          grepl("Not Found|404", conditionMessage(e), ignore.case = TRUE)) {
          return(invisible(NULL))
        }
        cli_abort("File {full_url} could not be downloaded. {e}")
      }
    )
  }
  invisible(NULL)
}

#' Synchronises multiple remote files with local paths in parallel
#'
#' Uses curl::multi_download for concurrent async I/O downloads, processing
#' files in batches to avoid overwhelming the remote server with too many
#' simultaneous connections. Falls back to sequential downloads if parallel
#' downloads are disabled.
#'
#' @param urls A character vector of URLs to download
#' @param output_files A character vector of local file paths (same length as urls)
#' @param progress Whether to show a progress bar (default TRUE)
#' @importFrom curl multi_download
#' @importFrom cli cli_alert_info cli_alert_warning cli_abort
#' @importFrom tools md5sum
#' @return The output_files vector, invisibly
#' @keywords internal
#' @noRd
sync_remote_files <- function(urls, output_files, progress = TRUE,
                              ignore_not_found = FALSE) {
  if (length(urls) == 0) {
    return(invisible(character(0)))
  }
  if (length(urls) != length(output_files)) {
    cli_abort("urls and output_files must have the same length")
  }

  # For files that already exist, batch-verify integrity using a single round
  # of parallel HEAD requests (returns both Content-Length and ETag).
  # Stage 1 (size): no file I/O — catches partial downloads instantly.
  # Stage 2 (MD5):  only reached when sizes match — catches rare corruption.
  # Corrupt files are deleted so the to_download mask picks them up below.
  already_cached <- file.exists(output_files)
  if (any(already_cached) && isTRUE(getOption("cellNexus.check_cache_integrity", TRUE))) {
    head_info <- url_file_head_info(urls[already_cached])
    cached_files <- output_files[already_cached]

    # Stage 1: size check (no file reads)
    size_known <- !is.na(head_info$size_bytes)
    size_ok <- !size_known | (file.size(cached_files) == head_info$size_bytes)

    # Stage 2: MD5 check (reads files whose sizes are correct)
    etag_known <- !is.na(head_info$etag) & size_ok
    local_md5s <- rep(NA_character_, length(cached_files))
    if (any(etag_known)) {
      local_md5s[etag_known] <- unname(tools::md5sum(cached_files[etag_known]))
    }
    md5_ok <- !etag_known | (tolower(head_info$etag) == tolower(local_md5s))

    corrupt <- !size_ok | !md5_ok
    if (any(corrupt)) {
      cli_alert_warning(
        "{sum(corrupt)} cached file{?s} failed integrity check (partial or corrupt download). Re-downloading."
      )
      file.remove(cached_files[corrupt])
    }
  }

  # Filter to only files that don't exist (includes just-deleted corrupt ones)
  to_download <- !file.exists(output_files)
  urls_to_download <- urls[to_download]
  files_to_download <- output_files[to_download]

  if (length(urls_to_download) == 0) {
    return(invisible(output_files))
  }

  # Create directories for all output files
  unique_dirs <- unique(dirname(files_to_download))
  for (dir in unique_dirs) {
    dir.create(dir, recursive = TRUE, showWarnings = FALSE)
  }

  use_parallel <- getOption("cellNexus.parallel_downloads", TRUE)

  if (use_parallel && length(urls_to_download) > 1) {
    cli_alert_info("Downloading {length(urls_to_download)} file{?s} in parallel...")

    # Download in batches to avoid overwhelming the server with too many
    # simultaneous connections. Sending thousands of requests at once causes
    # the Nectar OpenStack Swift server to reject the excess with HTTP 4xx/5xx.
    # The batch size can be tuned via options(cellNexus.download_batch_size = N).
    batch_size <- getOption("cellNexus.download_batch_size", 500L)
    batches <- split(
      seq_along(urls_to_download),
      ceiling(seq_along(urls_to_download) / batch_size)
    )

    n_failed_total <- 0L
    for (batch_idx in seq_along(batches)) {
      idx <- batches[[batch_idx]]
      batch_urls <- urls_to_download[idx]
      batch_files <- files_to_download[idx]

      if (length(batches) > 1L) {
        cli_alert_info(
          "Batch {batch_idx}/{length(batches)}: {length(idx)} file{?s}..."
        )
      }

      # Use curl::multi_download for parallel async I/O
      # Note: multiplex=TRUE enables HTTP/2 multiplexing for concurrent streams
      results <- multi_download(
        urls = batch_urls,
        destfiles = batch_files,
        progress = progress,
        multiplex = TRUE
      )

      # Check for failures.
      # results$success can be TRUE (ok), FALSE (explicit failure), or NA
      # (request was still in-progress when multi_run was interrupted, e.g. the
      # user pressed ESC or the process was killed).  Without the is.na() guard,
      # leaving partial files on disk that are silently reused on the next run.
      failed <- is.na(results$success) |
        !results$success |
        (!is.na(results$status_code) & results$status_code >= 400)
      if (any(failed)) {
        failed_files <- batch_files[failed]
        for (f in failed_files) {
          if (file.exists(f)) file.remove(f)
        }
        n_failed_total <- n_failed_total + sum(failed)
      }
    }

    if (n_failed_total > 0L) {
      cli_alert_warning("{n_failed_total} file{?s} failed to download")
      if (!ignore_not_found && n_failed_total == length(urls_to_download)) {
        cli_abort("All downloads failed. Check your network connection.")
      }
    }
  } else {
    # Sequential fallback
    for (i in seq_along(urls_to_download)) {
      sync_remote_file(
        urls_to_download[i], files_to_download[i],
        ignore_not_found = ignore_not_found
      )
    }
  }

  invisible(output_files)
}

#' Returns a tibble from a parquet file path
#' Since dbplyr 2.4.0, raw file paths aren't handled very well
#' See: <https://github.com/duckdb/duckdb-r/issues/38>
#' Hence the need for this method
#' @param conn A DuckDB connection.
#' @param path Path(s) to parquet file(s).
#' @importFrom dplyr tbl
#' @importFrom dbplyr sql
#' @importFrom glue glue_sql
#' @return An SQL data frame
#' @keywords internal
#' @noRd
duckdb_read_parquet <- function(conn, path) {
  from_clause <- glue_sql("FROM read_parquet([{`path`*}], union_by_name=true)", .con = conn) |>
    sql()
  tbl(conn, from_clause)
}

#' Check whether a column is all NA in a dataframe, drop the column and warn users
#' @return A data frame where all values are not NA
#' @keywords internal
#' @noRd
clean_and_report_NA_columns <- function(df) {
  na_column_names <- df |>
    dplyr::select(dplyr::where(~ all(is.na(.)))) |>
    names()
  if (length(na_column_names) > 0) {
    cli::cli_alert_info(
      "Dropping {.field {na_column_names}} because they contain only NA values."
    )
    df <- df |>
      dplyr::select(-dplyr::all_of(na_column_names))
  }
  df
}

#' Duplicate Single-Column Assay in SingleCellExperiment Object
#'
#' This function handles SingleCellExperiment (SCE) objects where a specified assay
#' contains only one column. It duplicates the single-column assay to avoid potential
#' errors during saving or downstream analysis that require at least two columns.
#' The duplicated column is marked with a prefix `DUMMY___` to distinguish it.
#' Corresponding entries in the column metadata (`colData`) are also duplicated.
#'
#' @param sce A `SingleCellExperiment` object.
#' @importFrom SummarizedExperiment assay assays colData
#' @importFrom SingleCellExperiment SingleCellExperiment
#' @importFrom rlang set_names
#' @keywords internal
#' @noRd
duplicate_single_column_assay <- function(sce) {
  assay_name <- (sce |>
    assays() |>
    names())[[1L]]

  if (ncol(assay(sce)) == 1) {
    # Duplicate the assay to prevent saving errors due to single-column matrices
    my_assay <- cbind(assay(sce), assay(sce))
    # Rename the second column to distinguish it
    colnames(my_assay)[2] <- paste0("DUMMY", "___", colnames(my_assay)[2])

    cd <- colData(sce)
    cd <- cd |>
      rbind(cd)
    rownames(cd)[2] <- paste0("DUMMY", "___", rownames(cd)[2])

    sce <- SingleCellExperiment(
      assay = list(my_assay) |>
        set_names(assay_name),
      colData = cd
    )
    sce
  }
  sce
}

#' Keep high-quality cells based on QC columns
#'
#' @param data A data frame or tibble containing single-cell metadata.
#' @param empty_droplet_col A string specifying the column name
#'   that indicates empty droplets (default: `"empty_droplet"`).
#'   Expected logical vector
#' @param alive_col A string specifying the column name
#'   that indicates whether cells are alive (default: `"alive"`).
#'   Expected logical vector
#' @param doublet_col A string specifying the column name
#'   that indicates doublets (default: `"scDblFinder.class"`).
#'   Expected character vector: `"doublet"` and/or `"singlet"` and/or `"unknown"`.
#'
#' @return A filtered data frame containing only cells that pass all QC checks.
#' @examples
#' get_metadata(cloud_metadata = SAMPLE_DATABASE_URL, cache_directory = tempdir()) |>
#'   head(2) |>
#'   keep_quality_cells()
#' @export
#' @importFrom rlang .data
#' @importFrom dplyr filter
#' @source [Mangiola et al.,2023](https://www.biorxiv.org/content/10.1101/2023.06.08.542671v3)
keep_quality_cells <- function(data,
                               empty_droplet_col = "empty_droplet",
                               alive_col = "alive",
                               doublet_col = "scDblFinder.class") {
  data |>
    filter(
      !.data[[empty_droplet_col]],
      .data[[alive_col]],
      .data[[doublet_col]] != "doublet"
    )
}

#' Identify annotation columns determined by key column(s)
#'
#' Returns names of columns that do not vary within each combination of `.col`
#' (functionally determined by the keys). Useful for keeping sample- or
#' pseudobulk-grain annotations and dropping cell-level columns.
#'
#' A non-key column `x` is kept when
#' `n_distinct(.col..., x) == n_distinct(.col...)`.
#'
#' Works on local data frames and lazy DuckDB tables from [get_metadata()].
#'
#' @param .data A data frame or lazy table (e.g. from [get_metadata()]).
#' @param .col Tidyselect keys, e.g. `sample_id`,
#'   `c(sample_id, cell_type_unified_ensemble)`, or `contains("cell_type")`.
#' @param sample_n Optional positive integer. If set, randomly sample this many
#'   rows with [dplyr::slice_sample()] before checking (lazy on DuckDB). Faster
#'   but approximate.
#' @param include_query_columns Logical. If `TRUE`, include the columns
#'   selected by `.col` in the result. Default `FALSE`.
#'
#' @return A character vector of column names determined by `.col`.
#'
#' @examples
#' meta <- get_metadata(cloud_metadata = SAMPLE_DATABASE_URL) |> head(1000)
#' get_specific_annotation_columns(meta, sample_id)
#' get_specific_annotation_columns(
#'   meta,
#'   c(sample_id, cell_type_unified_ensemble),
#'   sample_n = 5000L
#' )
#' get_specific_annotation_columns(meta, contains("cell_type"), sample_n = 5000L)
#' @keywords internal
#' @noRd
#' @importFrom dplyr select summarise collect n_distinct slice_sample
#' @importFrom rlang syms expr sym
#' @importFrom cli cli_abort
get_specific_annotation_columns <- function(.data, .col, sample_n = NULL,
                                            include_query_columns = TRUE) {
  if (!is.null(sample_n)) {
    .data <- slice_sample(.data, n = sample_n)
  }

  key_names <- .data |>
    select({{ .col }}) |>
    colnames()
  if (!length(key_names)) {
    cli_abort("No key columns selected by {.arg .col}.")
  }

  other_cols <- setdiff(colnames(.data), key_names)
  if (!length(other_cols)) {
    return(if (include_query_columns) key_names else character())
  }

  key_exprs <- syms(key_names)
  dots <- lapply(other_cols, function(col) {
    expr(n_distinct(!!!key_exprs, !!sym(col)))
  })
  names(dots) <- other_cols

  counts <- .data |>
    summarise(
      n_key = n_distinct(!!!key_exprs),
      !!!dots
    ) |>
    collect()

  specific_cols <- other_cols[as.numeric(counts[other_cols]) == counts$n_key]
  if (include_query_columns) {
    specific_cols <- c(key_names, specific_cols)
  }

  return(specific_cols)
}

#' Keep key columns and annotations determined by them
#'
#' Selects `.col` plus columns returned by `get_specific_annotation_columns()`.
#' Useful for reducing cell-level metadata to sample- or pseudobulk-grain
#' annotations before building `colData`.
#'
#' @param .data A data frame or lazy table (e.g. from [get_metadata()]).
#' @param .col Tidyselect keys, e.g. `sample_id`,
#'   `c(sample_id, cell_type_unified_ensemble)`, or `contains("cell_type")`.
#' @param sample_n Optional positive integer. If set, randomly sample this many
#'   rows with [dplyr::slice_sample()] before checking (lazy on DuckDB). Faster
#'   but approximate.
#' @param include_query_columns Logical. If `TRUE`, include the columns
#'   selected by `.col` in the result.
#'
#' @return `.data` with only the key columns and columns functionally
#'   determined by them.
#'
#' @examples
#' meta <- get_metadata(cloud_metadata = SAMPLE_DATABASE_URL) |> head(1000)
#' meta |> keep_specific_annotation_columns(c(sample_id, cell_type_unified_ensemble))
#' @keywords internal
#' @noRd
#' @importFrom dplyr select all_of
keep_specific_annotation_columns <- function(.data, .col, sample_n = NULL, include_query_columns = TRUE) {
  cols <- get_specific_annotation_columns(
    .data,
    {{ .col }},
    sample_n = sample_n,
    include_query_columns = include_query_columns
  )
  select(.data, all_of(cols)) |> distinct()
}
