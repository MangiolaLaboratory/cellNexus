\name{NEWS}
\title{News for Package \pkg{cellNexus}}

\\section{News in version 0.99.9}{
\\itemize{
    \\item Documentation updates. Clarified the \\code{features} parameter docs for all three functions to describe the drop-and-align behavior; regenerated help files. Updated \\code{get_pseudobulk()} documentation to state that it returns a \\code{SingleCellExperiment} by default and added the \\code{as_SummarizedExperiment} argument.
    \\item Tests. Added a test verifying pseudobulk subsetting to the specific feature \\code{ENSG00000065485}, and a test ensuring that rownames are preserved when coercing \\code{get_pseudobulk()} output to \\code{SummarizedExperiment}.
}}
\\section{News in version 0.99.4}{
\\itemize{
    \\item Consistent features handling across retrieval functions. \\code{get_pseudobulk()}, \\code{get_single_cell_experiment()}, and \\code{get_metacell()} now drop experiments/samples that do not contain all requested features and align rows to the requested feature set before merging. A warning indicates how many experiments were dropped.
    \\item Stabilised feature subsetting during merge to avoid index/subscript errors and ensure identical row order across experiments prior to \\code{cbind()}.
    \\item Qualified functional calls (e.g., \\code{purrr::map_lgl}) to avoid missing import issues.
}}

\section{News in version 0.1.0}{
\itemize{
    \item Added a NEWS file to track changes to the package.
}}
