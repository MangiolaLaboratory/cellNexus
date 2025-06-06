% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/seurat.R
\name{get_seurat}
\alias{get_seurat}
\title{Given a data frame of HCA metadata, returns a Seurat object corresponding to
the samples in that data frame}
\source{
\href{https://www.biorxiv.org/content/10.1101/2023.06.08.542671v3}{Mangiola et al.,2023}
}
\usage{
get_seurat(...)
}
\arguments{
\item{...}{
  Arguments passed on to \code{\link[=get_single_cell_experiment]{get_single_cell_experiment}}
  \describe{
    \item{\code{data}}{A data frame containing, at minimum, \code{cell_id}, \code{file_id_cellNexus_single_cell}
and \code{atlas_id} columns, which correspond to a single cell ID, file subdivision for internal use,
and atlas name in format (e.g cellxgene/06-02-2025) for internal use.
They can be obtained from the \code{\link[=get_metadata]{get_metadata()}} function.}
    \item{\code{assays}}{A character vector specifying the desired assay(s) to be requested.
Valid elements include "counts", "cpm", and "rank" for single-cell analyses, or
"counts" for pseudobulk analyses.
The default setting retrieves only the counts assay.
If your analysis involves a smaller set of genes, consider using the "cpm" assay.
The "rank" assay is suited for signature calculations across millions of cells.}
    \item{\code{cell_aggregation}}{A character vector that specifies which cell aggregation
strategy should be applied. This will create a corresponding subdirectory
in the cache directory. Single cell level is applied by default.}
    \item{\code{cache_directory}}{An optional character vector of length one. If
provided, it should indicate a local file path where any remotely accessed
files should be copied.}
    \item{\code{repository}}{A character vector of length one. If provided, it should be
an HTTP URL pointing to the location where the single cell data is stored.}
    \item{\code{features}}{An optional character vector of features (ie genes) to return
the counts for. By default counts for all features will be returned.}
  }}
}
\value{
A Seurat object containing the same data as a call to
\code{\link[=get_single_cell_experiment]{get_single_cell_experiment()}}
}
\description{
Given a data frame of HCA metadata, returns a Seurat object corresponding to
the samples in that data frame
}
\examples{
meta <- get_metadata() |> head(2)
seurat <- get_seurat(meta)
}
\references{
Mangiola, S., M. Milton, N. Ranathunga, C. S. N. Li-Wai-Suen,
A. Odainic, E. Yang, W. Hutchison et al. "A multi-organ map of the human
immune system across age, sex and ethnicity." bioRxiv (2023): 2023-06.
doi:10.1101/2023.06.08.542671.
}
