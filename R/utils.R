# Utility scripts that are used internally by the package at runtime

#' Gets the file size of a number of remote files
#' @param urls A character vector containing URLs
#' @return The file size of each of the files pointed to by the provided URL,
#' in gigabytes, as double vector
#' @importFrom purrr map_dbl
#' @importFrom httr HEAD
#' @keywords internal
#' @source [Mangiola et al.,2023](https://www.biorxiv.org/content/10.1101/2023.06.08.542671v3)
url_file_size <- function(urls){
    map_dbl(urls, function(url){
        as.numeric(
            HEAD(url)$headers$`content-length` 
        ) / 10^9
    })
}

#' Prints a message indicating the size of a download
#' @inheritParams url_file_size
#' @importFrom cli cli_alert_info
#' @keywords internal
#' @return `NULL`, invisibly
#' @source [Mangiola et al.,2023](https://www.biorxiv.org/content/10.1101/2023.06.08.542671v3)
report_file_sizes <- function(urls){
    total_size <- url_file_size(urls) |> 
        sum() |>
        round(digits=2)
    
    "Downloading {length(urls)} file{?s}, totalling {total_size} GB" |>
        cli_alert_info()
    
    invisible(NULL)
}

#' Formats a multi-line string as it it were on one line
#' @param text Any character vector
#' @return The same character vector, with newlines and subsequent whitespace
#'   removed
#' @keywords internal
#' @source [Mangiola et al.,2023](https://www.biorxiv.org/content/10.1101/2023.06.08.542671v3)
single_line_str <- function(text){
  stringr::str_remove_all(text, r"(\n\s*)")
}

#' Returns the default cache directory with a version number
#' @export
#' @return A length one character vector.
#' @importFrom tools R_user_dir
#' @importFrom utils packageName
#' @examples
#' get_metadata(cloud_metadata = SAMPLE_DATABASE_URL, cache_directory = get_default_cache_dir())
#' @references Mangiola, S., M. Milton, N. Ranathunga, C. S. N. Li-Wai-Suen, 
#'   A. Odainic, E. Yang, W. Hutchison et al. "A multi-organ map of the human 
#'   immune system across age, sex and ethnicity." bioRxiv (2023): 2023-06.
#'   doi:10.1101/2023.06.08.542671.
#' @source [Mangiola et al.,2023](https://www.biorxiv.org/content/10.1101/2023.06.08.542671v3)
get_default_cache_dir <- function() {
    packageName() |>
        R_user_dir(
            "cache"
        ) |>
        normalizePath() |>
        suppressWarnings()
}

#' Clear the default cache directory
#' @return A length one character vector.
#' @keywords internal
#' @noRd
clear_cache <- function() {
  get_default_cache_dir() |> unlink(TRUE, TRUE)
}

#' Clear the outdated metadata in the default cache directory.
#' @param updated_data A character vector of outdated metadata name
#' @return `NULL`, invisibly
#' @keywords internal
#' @source [Mangiola et al.,2023](https://www.biorxiv.org/content/10.1101/2023.06.08.542671v3)
clear_old_metadata <- function(updated_data) {
  cache_directory <- get_default_cache_dir()
  files_in_cache <- list.files(cache_directory)
  pattern <- "\\.parquet$"
  parquet_files <- grep(pattern, files_in_cache, value = TRUE)
  files_to_delete <- setdiff(parquet_files, updated_data)
  unlink(file.path(cache_directory, files_to_delete))
} 

#' Synchronises a single remote file with a local path
#' @importFrom httr write_disk GET stop_for_status
#' @importFrom cli cli_abort cli_alert_info
#' @return `NULL`, invisibly
#' @keywords internal
#' @source [Mangiola et al.,2023](https://www.biorxiv.org/content/10.1101/2023.06.08.542671v3)
sync_remote_file <- function(full_url, output_file, ...) {
    if (!file.exists(output_file)) {
        output_dir <- dirname(output_file)
        dir.create(output_dir,
                   recursive = TRUE,
                   showWarnings = FALSE
        )
        cli_alert_info("Downloading {full_url} to {output_file}")
        
        tryCatch(
            GET(full_url, write_disk(output_file), ...) |> stop_for_status(),
            error = function(e) {
                # Clean up if we had an error
                file.remove(output_file)
                cli_abort("File {full_url} could not be downloaded. {e}")
            }
        )
    }
    invisible(NULL)
}

#' Returns a tibble from a parquet file path
#' Since dbplyr 2.4.0, raw file paths aren't handled very well
#' See: <https://github.com/duckdb/duckdb-r/issues/38>
#' Hence the need for this method
#' @param filename_column A column name to the metadata that indicates which row came from which file. 
#' By default it does not add the column.
#' @importFrom glue glue
#' @importFrom dplyr tbl
#' @importFrom dbplyr sql
#' @importFrom glue glue_sql
#' @return An SQL data frame
#' @keywords internal
#' @source [Mangiola et al.,2023](https://www.biorxiv.org/content/10.1101/2023.06.08.542671v3)
read_parquet <- function(conn, path, filename_column=FALSE){
    from_clause <- glue_sql("FROM read_parquet([{`path`*}], union_by_name=true, filename={filename_column})", .con=conn) |> sql()
    tbl(conn, from_clause)
}

#' Deletes specific counts and metadata from cache
#' @importFrom purrr map
#' @importFrom dplyr filter distinct pull collect
#' @return `NULL`, invisibly
#' @keywords internal
#' @source [Mangiola et al.,2023](https://www.biorxiv.org/content/10.1101/2023.06.08.542671v3)
delete_counts <- function(data, 
                          assay = c("original","cpm"), 
                          cache_directory = get_default_cache_dir()){
  data <- collect(data)
  ids <- data |> distinct(file_id_db) |> pull(file_id_db)
  counts_path <- file.path(cache_directory, assay, ids)
  # counts
  map(counts_path, ~ .x |> unlink(recursive = TRUE))
  
  # metadata
  filename <- get_metadata(cache_directory = cache_directory, filename_column = "meta_filename", use_cache = FALSE ) |> 
    filter(file_id_db %in% ids) |> distinct(meta_filename) |> pull(meta_filename)
  arrow::read_parquet(filename) |> filter(!file_id_db %in% ids) |>
    arrow::write_parquet(filename)
}

#' Write table to Parquet file using DuckDB
#' This function takes an SQL table, renders it into an SQL query, and writes the output directly
#' to a Parquet file without loading into disk.
#' @param .tbl_sql A data frame loaded by DuckDB.
#' @param path A string specifying the file path where the Parquet file will be saved.
#' @param con A DuckDB connection object that allows executing SQL queries on the DuckDB database.
#' @return An integer specifying the row number of the output data frame.
#' @importFrom DBI dbConnect dbExecute
#' @keywords internal
#' @noRd
#' @source [Mangiola et al.,2023](https://www.biorxiv.org/content/10.1101/2023.06.08.542671v3)
duckdb_write_parquet <- function(.tbl_sql, 
                                 path, 
                                 con = dbConnect(duckdb::duckdb(),  dbdir = ":memory:")) {
  sql_tbl <- 
    .tbl_sql |>
    dbplyr::sql_render()
  
  sql_call <- glue::glue("COPY ({sql_tbl}) TO '{path}' (FORMAT 'parquet')")
  
  res <- dbExecute(con, sql_call)
  res
}

#' Check whether a column is all NA in a dataframe, drop the column and warn users
#' @return A data frame where all values are not NA
#' @keywords internal
#' @noRd
#' @source [Mangiola et al.,2023](https://www.biorxiv.org/content/10.1101/2023.06.08.542671v3)
clean_and_report_NA_columns <- function(df) {
  na_column_names <- df |> select(where(~all(is.na(.)))) |> names()
  
  "Dropping {na_column_names} as they all contain only NA values" |>
    cli_alert_info()
  df |> select(-all_of(na_column_names))
}

#' Save anndata
#' @return `NULL`, invisible
#' @noRd
#' @keywords internal
#' @source [Mangiola et al.,2023](https://www.biorxiv.org/content/10.1101/2023.06.08.542671v3)
write_h5ad <- function(sce,
                       path) {
  selected_columns <- sce |> SummarizedExperiment::colData() |> 
    as.data.frame() |> clean_and_report_NA_columns() |> names()
  
  colData_subset = colData(sce)[, selected_columns]
  colData(sce) <- colData_subset
  
  if (ncol(SummarizedExperiment::assay(sce)) == 1) sce = sce |> duplicate_single_column_assay()
  
  sce |> anndataR::write_h5ad(path, compression = "gzip", verbose = FALSE)
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
#' @noRd
#' @importFrom SummarizedExperiment assay assays colData
#' @importFrom SingleCellExperiment SingleCellExperiment
#' @importFrom rlang set_names
#' @keywords internal
duplicate_single_column_assay <- function(sce) {
  
  assay_name = sce |> assays() |> names() |> magrittr::extract2(1)
  
  if(ncol(assay(sce)) == 1) {
    
    # Duplicate the assay to prevent saving errors due to single-column matrices
    my_assay = cbind(assay(sce), assay(sce))
    # Rename the second column to distinguish it
    colnames(my_assay)[2] = paste0("DUMMY", "___", colnames(my_assay)[2])
    
    cd = colData(sce)
    cd = cd |> rbind(cd)
    rownames(cd)[2] = paste0("DUMMY", "___", rownames(cd)[2])
    
    sce =  SingleCellExperiment(assay = list(my_assay) |> set_names(assay_name), colData = cd)
    sce
  } 
  sce
}

#' Synchronize metadata assay files with remote repository
#' 
#' @description Downloads and caches assay files from a remote repository based on metadata specifications.
#'
#' @param data A data frame or tbl_sql containing metadata with required columns `cell_id`, `atlas_id`, and a grouping column
#' @param assays Character vector specifying which assays to sync
#' @param repository URL of the remote repository containing the assay files
#' @param cell_aggregation Character string specifying the cell aggregation strategy 
#' @param grouping_column Column name in data used to group files for synchronization
#' @param cache_directory Local directory path where files will be cached. Uses default cache if not specified
#'
#' @return `NULL`, invisibly. Progress messages are displayed for the downloads.
#' 
#' @importFrom dplyr pull transmute distinct
#' @importFrom assertthat assert_that has_name
#' @importFrom cli cli_alert_info
#' @importFrom purrr pmap
#' @importFrom httr parse_url
#' @importFrom rlang .data
#' @source [Mangiola et al.,2023](https://www.biorxiv.org/content/10.1101/2023.06.08.542671v3)
sync_metadata_assay_files <- function(data,
                                      assays = "counts",
                                      repository = COUNTS_URL,
                                      cell_aggregation = "",
                                      grouping_column,
                                      cache_directory = get_default_cache_dir()
) {
  assert_that(
    all(c("cell_id", "atlas_id", grouping_column) %in% colnames(data))
  )
  atlas_name <- data |> pull(atlas_id) |> unique()
  
  subdirs <- assay_map[assays]
  
  if (!is.null(repository)) {
    cli_alert_info("Synchronising files")
    parsed_repo <- parse_url(repository)
    parsed_repo$scheme |>
      `%in%`(c("http", "https")) |>
      assert_that()
    
    files_to_read <-
      data |> 
      transmute(
        files = .data[[grouping_column]], 
        atlas_name = atlas_id, 
        cache_dir = cache_directory
      ) |>  distinct() |> 
      # Convert to tibble here to avoid breaking the memory after loading all metadata 
      tibble::as_tibble() |> 
      pmap(function(files, atlas_name, cache_dir) {
        sync_assay_files(
          files = files,
          atlas_name = atlas_name,
          cache_dir = cache_dir,
          url = parsed_repo,
          cell_aggregation = cell_aggregation,
          subdirs = subdirs
        )
      })
  }
}

