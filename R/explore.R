#' Show the tissues available in cellNexus
#'
#' Returns the tissue and tissue group combinations available in the
#' harmonised metadata database.
#'
#' @param metadata Optional metadata table returned by [get_metadata()]. If
#'   `NULL`, metadata is retrieved using the remaining arguments.
#' @param cloud_metadata,local_metadata,cache_directory,use_cache Arguments
#'   passed to [get_metadata()] when `metadata` is `NULL`.
#' @return A tibble with `tissue` and `tissue_groups` columns.
#' @export
#' @examples
#' show_tissues()
show_tissues <- function(metadata = NULL,
                         cloud_metadata = get_metadata_url("hca_2024"),
                         local_metadata = NULL,
                         cache_directory = get_default_cache_dir(),
                         use_cache = TRUE) {
  if (is.null(metadata)) {
    metadata <- get_metadata(
      cloud_metadata = cloud_metadata,
      local_metadata = local_metadata,
      cache_directory = cache_directory,
      use_cache = use_cache
    )
  }

  metadata |>
    dplyr::distinct(tissue, tissue_groups) |>
    dplyr::arrange(tissue, tissue_groups) |>
    dplyr::collect()
}

#' Show datasets available for a tissue
#'
#' Returns the datasets available in the harmonised metadata database,
#' optionally restricted to one or more tissues and tissue groups.
#'
#' @param tissue Optional character vector of tissues to include.
#' @param tissue_groups Optional character vector of tissue groups to include.
#' @param metadata Optional metadata table returned by [get_metadata()]. If
#'   `NULL`, metadata is retrieved using the remaining arguments.
#' @param cloud_metadata,local_metadata,cache_directory,use_cache Arguments
#'   passed to [get_metadata()] when `metadata` is `NULL`.
#' @return A tibble with `dataset_id`, `tissue`, and `tissue_groups` columns.
#' @export
#' @examples
#' show_datasets(tissue_groups = "blood")
show_datasets <- function(tissue = NULL,
                          tissue_groups = NULL,
                          metadata = NULL,
                          cloud_metadata = get_metadata_url("hca_2024"),
                          local_metadata = NULL,
                          cache_directory = get_default_cache_dir(),
                          use_cache = TRUE) {
  if (is.null(metadata)) {
    metadata <- get_metadata(
      cloud_metadata = cloud_metadata,
      local_metadata = local_metadata,
      cache_directory = cache_directory,
      use_cache = use_cache
    )
  }

  if (!is.null(tissue)) {
    metadata <- metadata |>
      dplyr::filter(.data$tissue %in% tissue)
  }
  if (!is.null(tissue_groups)) {
    metadata <- metadata |>
      dplyr::filter(.data$tissue_groups %in% tissue_groups)
  }

  metadata |>
    dplyr::distinct(dataset_id, tissue, tissue_groups) |>
    dplyr::arrange(tissue, tissue_groups, dataset_id) |>
    dplyr::collect()
}
