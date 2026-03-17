#' cellNexus: Query Interface for the Human Cell Atlas
#'
#' \code{cellNexus} provides a query interface for programmatic exploration
#' and retrieval of the harmonised, curated and reannotated CELLxGENE
#' single-cell Human Cell Atlas. The package allows users to query metadata
#' and download single-cell RNA sequencing data in various formats including
#' SingleCellExperiment, Seurat, and pseudobulk SummarizedExperiment objects.
#'
#' @section Getting Started:
#' To get started with \code{cellNexus}, first load the package and retrieve
#' the metadata:
#'
#' \preformatted{
#' library(cellNexus)
#' metadata <- get_metadata()
#' }
#'
#' Then filter the metadata to find cells of interest and download the data:
#'
#' \preformatted{
#' filtered_metadata <- metadata |>
#'     dplyr::filter(
#'         tissue == "lung parenchyma" &
#'         cell_type \%LIKE\% "\%CD4\%"
#'     )
#' 
#' sce <- get_single_cell_experiment(filtered_metadata)
#' }
#'
#' @section Main Functions:
#' \describe{
#'   \item{\code{\link{get_metadata}}}{Retrieve and query the harmonised metadata}
#'   \item{\code{\link{get_single_cell_experiment}}}{Download data as SingleCellExperiment objects}
#'   \item{\code{\link{get_seurat}}}{Download data as Seurat objects}
#'   \item{\code{\link{get_pseudobulk}}}{Download aggregated pseudobulk data}
#'   \item{\code{\link{get_metacell}}}{Download metacell aggregated data}
#' }
#'
#' @section Data Licensing:
#' \strong{Important:} The Human Cell Atlas data accessed through this package
#' is subject to its own licensing terms, which differ from the package license.
#' The \code{cellNexus} package itself is licensed under GPL-3. However, the
#' underlying Human Cell Atlas data is typically licensed under Creative Commons
#' Attribution (CC-BY) or similar open data licenses as specified by the
#' Human Cell Atlas Data Use Agreement. Users should review the specific
#' licensing terms for any datasets they access through this package.
#' For more information, see the Human Cell Atlas Data Portal:
#' \url{https://data.humancellatlas.org/about}
#'
#' @section Vignettes:
#' See \code{vignette("cellNexus", package = "cellNexus")} for a comprehensive
#' introduction to using the package.
#'
#' @source [Mangiola et al.,2023](https://www.biorxiv.org/content/10.1101/2023.06.08.542671v3)
#'
#' @references
#' Mangiola, S., M. Milton, N. Ranathunga, C. S. N. Li-Wai-Suen,
#' A. Odainic, E. Yang, W. Hutchison et al. "A multi-organ map of the human
#' immune system across age, sex and ethnicity." bioRxiv (2023): 2023-06.
#' doi:10.1101/2023.06.08.542671.
#'
#' @name cellNexus-package
#' @return The cellNexus package (invisibly).
#' @aliases cellNexus-package cellNexus
NULL

#' @importFrom purrr walk
#' @importFrom dbplyr remote_con
#' @importFrom DBI dbDisconnect
#' @keywords internal
#' @noRd
.onUnload <- function(libname, pkgname) {
    # Close connections to all cached tables. This should avoid most of the
    # "Connection is garbage-collected" messages
    cache$metadata_table |>
        as.list() |>
        walk(function(table) {
            table |>
                remote_con() |>
                dbDisconnect()
        })
}

#' Attach `dplyr` on package attach
#'
#' This hook attaches `dplyr` when `cellNexus` is attached (e.g.
#' `library(cellNexus)`), so users can use common `dplyr` verbs without the
#' `dplyr::` prefix in interactive workflows. Startup messages are suppressed.
#'
#' @param libname The library path where the package is installed.
#' @param pkgname The name of the package being attached.
#' @keywords internal
#' @noRd
.onAttach <- function(libname, pkgname) {
  if (!"package:dplyr" %in% search()) {
    if (requireNamespace("dplyr", quietly = TRUE)) {
      suppressPackageStartupMessages(attachNamespace("dplyr"))
    }
  }
}

