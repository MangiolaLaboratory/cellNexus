# Functions that relate to the harmonised metadata database

#' @include utils.R
NULL

#' Environment that we use to cache the DuckDB connections
#' @noRd
cache <- rlang::env(
  metadata_table = rlang::env()
)

#' Returns the URLs for all metadata files 
#' @param databases A character vector specifying the names of the metadata files. 
#'   Download the specific metadata by defining the metadata version. By default, it uses
#'   metadata.1.2.13.parquet
#' @param use_split_files Logical, default `FALSE`. If `TRUE`, returns 
#'   URLs for the split metadata files.
#' @param use_census Logical, default `FALSE`. If `TRUE`, returns the URL 
#'   for the census metadata file.
#' @param use_metacell Logical, default `FALSE`. If `TRUE`, returns the URL 
#'   for the metacell metadata file.
#' @export
#' @return A character vector of URLs to parquet files to download
#' @examples
#' get_metadata_url("metadata.1.2.13.parquet")
#' @references Mangiola, S., M. Milton, N. Ranathunga, C. S. N. Li-Wai-Suen, 
#'   A. Odainic, E. Yang, W. Hutchison et al. "A multi-organ map of the human 
#'   immune system across age, sex and ethnicity." bioRxiv (2023): 2023-06.
#'   doi:10.1101/2023.06.08.542671.
#' @source [Mangiola et al.,2023](https://www.biorxiv.org/content/10.1101/2023.06.08.542671v3)
get_metadata_url <- function(databases  = "metadata.1.2.13.parquet", 
                             use_split_files = FALSE,
                             use_census = FALSE,
                             use_metacell = FALSE) {
  #clear_old_metadata(updated_data = databases)
  if (use_split_files) {
    # Return URLs for the three split files
    databases <- c("cellnexus_cell_metadata.1.2.13.parquet",
                   "sample_metadata.1.2.13.parquet")
  }
  
  if (use_census) {
    # Returns the URL for census metadata file
    databases <- "census_cell_metadata.1.2.13.parquet"
  }
  
  if (use_metacell) {
    # Returns the URL for metacell metadata file
    databases <- "metacell_metadata.1.2.13.parquet"
  }

  glue::glue(
    "https://object-store.rc.nectar.org.au/v1/AUTH_06d6e008e3e642da99d806ba3ea629c5/cellNexus-metadata/{databases}")
}

#' URL pointing to the sample metadata file, which is smaller and for test,
#' demonstration, and vignette purposes only
#' @export
#' @return A character scalar consisting of the URL
#' @examples
#' get_metadata(cloud_metadata = SAMPLE_DATABASE_URL, cache_directory = tempdir())
#' @references Mangiola, S., M. Milton, N. Ranathunga, C. S. N. Li-Wai-Suen, 
#'   A. Odainic, E. Yang, W. Hutchison et al. "A multi-organ map of the human 
#'   immune system across age, sex and ethnicity." bioRxiv (2023): 2023-06.
#'   doi:10.1101/2023.06.08.542671.
#' @source [Mangiola et al.,2023](https://www.biorxiv.org/content/10.1101/2023.06.08.542671v3)
SAMPLE_DATABASE_URL <- single_line_str(
  "https://object-store.rc.nectar.org.au/v1/
    AUTH_06d6e008e3e642da99d806ba3ea629c5/metadata/
    sample_metadata.0.2.3.parquet"
)

#' Internal function to prepare metadata for database connection
#'
#' This function handles the preparation of metadata files for database connection,
#' including downloading remote files, managing cache, and preparing file paths.
#' It's used internally by get_metadata() and is not intended for direct use.
#'
#' @param cloud_metadata Optional character vector of any length. HTTP URL/URLs pointing
#'   to the name and location of parquet database/databases. By default, it points to 
#'   cellNexus ARDC Nectar Research Cloud. Assign `NULL` to query local_metadata only 
#'   if exists.
#' @param local_metadata Optional character vector of any length representing the local
#'   path of parquet database(s).
#' @param cache_directory Optional character vector of length 1. A file path on
#'   your local system to a directory (not a file) that will be used to store
#'   metadata files.
#' @param use_cache Optional logical scalar. If `TRUE` (the default), and this
#'   function has been called before with the same parameters, then a cached
#'   reference to the table will be returned. If `FALSE`, a new connection will
#'   be created no matter what.
#' @param use_split_files Optional logical scalar. If `TRUE`, uses split metadata files
#'   instead of the single combined metadata file.
#' @return A list containing:
#'   \item{all_parquet}{Character vector of parquet file paths}
#'   \item{hash}{SHA256 hash of the file list for caching}
#'   \item{cached_connection}{Cached database connection if available and use_cache is TRUE}
#' @keywords internal
#' @noRd
get_metadata_base <- function(
    cloud_metadata = get_metadata_url(),
    local_metadata = NULL,
    cache_directory = get_default_cache_dir(),
    use_cache = TRUE,
    use_split_files = FALSE
) {
  # Handle split files
  if (isTRUE(use_split_files)) cloud_metadata <- get_metadata_url(use_split_files = TRUE)
  
  # Synchronize remote files
  walk(cloud_metadata, function(url) {
    # Calculate the file path from the URL
    path <- file.path(cache_directory, url |> basename())
    if (!file.exists(path)) {
      report_file_sizes(url)
      sync_remote_file(url, path, progress(type = "down", con = stderr()))
    }
  })
  
  if (is.null(cloud_metadata)) all_parquet <- c(local_metadata)
  if (!is.null(cloud_metadata)) all_parquet <- c(file.path(cache_directory, 
                                                           cloud_metadata |> basename()), 
                                                 local_metadata)
  
  # We try to avoid re-reading a set of parquet files 
  # that is identical to a previous set by hashing the file list
  hash <- all_parquet |> paste0(collapse="") |>
    hash_sha256()
  cached_connection <- cache$metadata_table[[hash]]
  
  list(
    all_parquet = all_parquet,
    hash = hash,
    cached_connection = if (isTRUE(use_cache)) cached_connection else NULL
  )
}

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
#'   your local system to a directory (not a file) that will be used to store
#'   `metadata.parquet`
#' @param use_cache Optional logical scalar. If `TRUE` (the default), and this
#'   function has been called before with the same parameters, then a cached
#'   reference to the table will be returned. If `FALSE`, a new connection will
#'   be created no matter what.
#' @param use_split_files Optional logical scalar. If `TRUE`, uses split metadata files
#'   instead of the single combined metadata file.
#' @param join_keys Character vector specifying the columns to join on when using
#'   multiple parquet files. Default is c("sample_id", "dataset_id").
#' @return A lazy data.frame subclass containing the metadata. You can interact
#'   with this object using most standard dplyr functions. For string matching,
#'   it is recommended that you use `stringr::str_like` to filter character
#'   columns, as `stringr::str_match` will not work.
#' @export
#' @examples
#' library(dplyr)
#' filtered_metadata <- get_metadata() |>
#'     filter(
#'         self_reported_ethnicity == "African" &
#'             assay %LIKE% "%10x%" &
#'             tissue == "lung parenchyma" &
#'             cell_type %LIKE% "%CD4%"
#'     )
#'
#' # Use split files for reduced download size (when available)
#' metadata_split <- get_metadata(use_split_files = TRUE)
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
#' Dataset-specific columns (definitions available at cellxgene.cziscience.com):
#' `cell_count`, `collection_id`, `created_at.x`, `created_at.y`,
#' `dataset_deployments`, `dataset_id`, `file_id_cellNexus_single_cell`, `filename`, `filetype`,
#' `is_primary_data.y`, `is_valid`, `linked_genesets`, `mean_genes_per_cell`,
#' `name`, `published`, `published_at`, `revised_at`, `revision`, `s3_uri`,
#' `schema_version`, `tombstone`, `updated_at.x`, `updated_at.y`,
#' `user_submitted`, `x_normalization`
#'
#' Sample-specific columns (definitions available at cellxgene.cziscience.com):
#' `sample_id`, `.sample_name`, `age_days`, `assay`, `assay_ontology_term_id`,
#' `development_stage`, `development_stage_ontology_term_id`, `ethnicity`,
#' `ethnicity_ontology_term_id`, `experiment___`, `organism`,
#' `organism_ontology_term_id`, `sample_placeholder`, `sex`,
#' `sex_ontology_term_id`, `tissue`, `tissue_harmonised`,
#' `tissue_ontology_term_id`, `disease`, `disease_ontology_term_id`,
#' `is_primary_data.x`
#'
#' Cell-specific columns (definitions available at cellxgene.cziscience.com):
#' `cell_id`, `cell_type`, `cell_type_ontology_term_idm`, `cell_type_harmonised`,
#' `confidence_class`, `cell_annotation_azimuth_l2`,
#' `cell_annotation_blueprint_singler`
#'
#' Through harmonisation and curation we introduced custom columns not present
#' in the original CELLxGENE metadata:
#'
#' - `tissue_harmonised`: a coarser tissue name for better filtering
#' - `age_days`: the number of days corresponding to the age
#' - `cell_type_harmonised`: the consensus call identity (for immune cells)
#'   using the original and three novel annotations using Seurat Azimuth and 
#'   SingleR
#' - `confidence_class`: an ordinal class of how confident
#'   `cell_type_harmonised` is. 1 is complete consensus, 2 is 3 out of four and
#'   so on.
#' - `cell_annotation_azimuth_l2`: Azimuth cell annotation
#' - `cell_annotation_blueprint_singler`: SingleR cell annotation using 
#'   Blueprint reference
#' - `cell_annotation_blueprint_monaco`: SingleR cell annotation using Monaco 
#'   reference
#' - `sample_id_db`: Sample subdivision for internal use
#' - `file_id_db`: File subdivision for internal use
#' - `sample_id`: Sample ID
#' - `.sample_name`: How samples were defined
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
#' @references Mangiola, S., M. Milton, N. Ranathunga, C. S. N. Li-Wai-Suen, 
#'   A. Odainic, E. Yang, W. Hutchison et al. "A multi-organ map of the human 
#'   immune system across age, sex and ethnicity." bioRxiv (2023): 2023-06.
#'   doi:10.1101/2023.06.08.542671.
#' @source [Mangiola et al.,2023](https://www.biorxiv.org/content/10.1101/2023.06.08.542671v3)
get_metadata <- function(cloud_metadata = get_metadata_url(),
                         local_metadata = NULL,
                         cache_directory = get_default_cache_dir(),
                         use_cache = TRUE,
                         use_split_files = FALSE,
                         join_keys = c("sample_id", "dataset_id")) {
  base <- get_metadata_base(cloud_metadata,
                            local_metadata,
                            cache_directory, 
                            use_cache,
                            use_split_files)
  if (!is.null(base$cached_connection)) return(base$cached_connection)
  
  table <- dbConnect(duckdb(), read_only = TRUE) |>
    read_and_join_parquets(path = base$all_parquet,
                           join_keys = join_keys)
  cache$metadata_table[[base$hash]] <- table
  table
}

#' Join census metadata with cellNexus metadata
#'
#' Downloads and joins the original census metadata with the provided cellNexus metadata.
#' This function creates indexed tables for efficient joining and returns a data frame.
#'
#' @param tbl_or_conn A tbl_sql object (from get_metadata) or a database connection
#' @return A lazy SQL table with census metadata joined to the cellNexus metadata
#' @export
#' @examples
#' \dontrun{
#' # Join census metadata with split files metadata
#' get_metadata(use_split_files = TRUE) |> join_census_table()
#' }
join_census_table <- function(tbl_or_conn) {
  conn <- get_conn(tbl_or_conn)

  # Extract census URL
  census_url = get_metadata_url(use_census = T)
  
  # Download metacell metadata if not exists
  census_path <- file.path(get_default_cache_dir(), basename(census_url))
  if (!file.exists(census_path)) {
    report_file_sizes(census_url)
    sync_remote_file(census_url, census_path, progress(type = "down", con = stderr()))
  }
  
# Clean up any existing tables
  tryCatch({
    dbExecute(conn, "DROP VIEW IF EXISTS temp_sample_cellnexus_cell_metadata")
  }, error = function(e) {
    # Ignore errors when dropping tables
  })
  
  # Create indexed table from census parquet (only if not exists). This avoid memory breaks when running query multiple times.
  if (!DBI::dbExistsTable(conn, "census_metadata")) {
    add_index_parquet(conn, census_path,
                      index_cols = c("sample_id", "dataset_id", "observation_joinid"),
                      table_name = "census_metadata")
  }
  
  # Create a temporary VIEW from the input tbl_sql (no materialisation)
  sql_base <- dbplyr::sql_render(tbl_or_conn)
  dbExecute(conn, paste0("CREATE TEMP VIEW temp_sample_cellnexus_cell_metadata AS ", sql_base))
  
  # Join the temporary view with census metadata
  sql_join <- "
    SELECT *
    FROM temp_sample_cellnexus_cell_metadata
    LEFT JOIN census_metadata USING (sample_id, dataset_id, observation_joinid)
  "
  
  tbl(conn, sql(sql_join))
}

#' Join metacell metadata with cellNexus metadata
#'
#' Downloads and joins the metacell metadata with the provided cellNexus metadata.
#' This function creates indexed tables for efficient joining and returns a data frame.
#'
#' @param tbl_or_conn A tbl_sql object (from get_metadata) or a database connection
#' @return A lazy SQL table with metacell metadata joined to the cellNexus metadata
#' @export
#' @examples
#' \dontrun{
#' # Join metacell metadata with split files metadata
#' get_metadata(use_split_files = TRUE) |> join_metacell_table()
#' }
join_metacell_table <- function(tbl_or_conn) {
  conn <- get_conn(tbl_or_conn)
  
  # Extract metacell URL
  metacell_url = get_metadata_url(use_metacell = T)
  
  # Download metacell metadata if not exists
  metacell_path <- file.path(get_default_cache_dir(), basename(metacell_url))
  if (!file.exists(metacell_path)) {
    report_file_sizes(metacell_url)
    sync_remote_file(metacell_url, metacell_path, progress(type = "down", con = stderr()))
  }
  
  # Clean up any existing tables
  tryCatch({
    dbExecute(conn, "DROP VIEW IF EXISTS temp_sample_cellnexus_cell_metadata")
  }, error = function(e) {
    # Ignore errors when dropping tables
  })
  
  # Create indexed table from metacell parquet (only if not exists). This avoid memory breaks when running query multiple times.
  if (!DBI::dbExistsTable(conn, "metacell_metadata")) {
    add_index_parquet(conn, metacell_path,
                      index_cols = c("sample_id", "dataset_id", "cell_id"),
                      table_name = "metacell_metadata")
  }
  
  # Create a temporary VIEW from the input tbl_sql (no materialisation)
  sql_base <- dbplyr::sql_render(tbl_or_conn)
  dbExecute(conn, paste0("CREATE TEMP VIEW temp_sample_cellnexus_cell_metadata AS ", sql_base))
  
  # Join the temporary view with metacell metadata
  sql_join <- "
    SELECT *
    FROM temp_sample_cellnexus_cell_metadata
    LEFT JOIN metacell_metadata USING (sample_id, dataset_id, cell_id)
  "
  
  tbl(conn, sql(sql_join))
}
