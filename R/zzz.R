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
#'         tissue_groups == "blood" &
#'         cell_type_unified_ensemble \%LIKE\% "\%cd4\%"
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
#' @references Shen, M., Y. Gao, N. Liu, D. Bhuva, M. Milton, J. Henao,
#'   J. Andrews, E. Yang, C. Zhan, N. Liu, S. Si, J. W. Hutchison,
#'   M. H. Shakeel, M. Morgan, A. T. Papenfuss, J. Iskander, J. M. Polo,
#'   and S. Mangiola. "cellNexus: Quality control, annotation, aggregation
#'   and analytical layers for the Human Cell Atlas data." bioRxiv (2026).
#'   doi:10.64898/2026.04.14.718336.
#'
#' @name cellNexus-package
#' @return The cellNexus package (invisibly).
#' @aliases cellNexus-package cellNexus
NULL

#' @keywords internal
#' @noRd
.onLoad <- function(libname, pkgname) {
  # Set default package options for parallel downloads
  op <- options()
  op.cellNexus <- list(
    cellNexus.parallel_downloads = TRUE,
    cellNexus.download_connections = 6L,
    # Verify locally cached files against the remote ETag (MD5) before reuse.
    # Two-stage check: file size (no I/O) then MD5 (reads file).
    # Disable with:  options(cellNexus.check_cache_integrity = FALSE)
    # Only disable when files are known to be intact.
    cellNexus.check_cache_integrity = TRUE
  )
  toset <- !(names(op.cellNexus) %in% names(op))
  if (any(toset)) options(op.cellNexus[toset])
  invisible()
}

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
        DBI::dbDisconnect()
    })
}

#' Attach `dplyr` on package attach
#'
#' This hook attaches `dplyr` when `cellNexus` is attached (e.g.
#' `library(cellNexus)`), so users can use common `dplyr` verbs without the
#' `dplyr::` prefix in interactive workflows. Startup messages are suppressed.
#' @keywords internal
#' @noRd
.onAttach <- function(libname, pkgname) {
  if (!"package:dplyr" %in% search()) {
    if (requireNamespace("dplyr", quietly = TRUE)) {
      suppressPackageStartupMessages(attachNamespace("dplyr"))
    }
  }
}
