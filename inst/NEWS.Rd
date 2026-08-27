\name{NEWS}
\title{News for Package \pkg{cellNexus}}

\section{News in version 0.99.33}{
\itemize{
    \item Batched parallel downloads: \code{sync_remote_files()} now splits large
    download queues into batches (default 500 files per batch) before passing
    them to \code{curl::multi_download()}.  Previously, all URLs were submitted
    in a single call; when requesting multiple assays simultaneously (e.g.\
    \code{assays = c("counts", "cpm", "rank")} over 1\,000 files = 3\,000
    requests), the Nectar OpenStack Swift server would reject the excess
    connections with HTTP 4xx/5xx responses, silently failing thousands of
    downloads.  Batching keeps each parallel burst below the server's
    per-account connection threshold.
    \itemize{
        \item The batch size defaults to 500 and can be adjusted via
        \code{options(cellNexus.download_batch_size = N)}.
        \item When more than one batch is required, a progress message is
        printed for each batch (e.g.\ \emph{Batch 2/6: 500 files...}).
        \item Failure counting is now accumulated across all batches so the
        final warning correctly reports the total number of files that could
        not be downloaded.
    }
    \item Cache integrity: \code{sync_remote_file()} and
    \code{sync_remote_files()} now verify that a locally cached file has not
    been partially downloaded or corrupted by comparing its MD5 digest against
    the remote object's ETag (OpenStack Swift stores the MD5 as the ETag for
    every object).  When a mismatch is detected the stale file is deleted and
    the download restarts cleanly, preventing silent failures on the second
    query after an interrupted first download.
    \itemize{
        \item New internal helper \code{url_file_head_info()} performs a single
        parallel batch of HEAD requests and returns both the \code{ETag} (MD5)
        and \code{Content-Length} for each URL.
        \item New internal helper \code{check_file_integrity()} uses a
        two-stage approach to avoid reading large files unnecessarily:
        \enumerate{
            \item \strong{Size check} (no file I/O): compare
            \code{file.size()} with \code{Content-Length}.  A mismatch means
            the file was partially downloaded and is caught immediately.
            \item \strong{MD5 check} (reads the file): compare
            \code{tools::md5sum()} with the ETag.  Only reached when sizes
            agree, guarding against silent disk corruption without penalising
            correctly cached files where the size is wrong.
        }
        \item \code{sync_remote_files()} retrieves both \code{Content-Length}
        and \code{ETag} in one parallel HEAD batch, then applies the two-stage
        check to all already-cached files before deciding which files need to
        be (re-)downloaded.
        \item \code{get_metadata()} and \code{sync_all_assay_files()} now pass
        the full file list to \code{sync_remote_files()} instead of
        pre-filtering to only missing files, so the integrity check fires for
        already-cached parquet and H5AD files too, not just freshly
        downloaded ones.
        \item Set \code{options(cellNexus.check_cache_integrity = FALSE)} to
        skip the integrity check only when the cache is known to be intact.
    }
}}

\section{News in version 0.99.32}{
\itemize{
    \item Added \code{download_only} argument (default \code{FALSE}) to
    \code{get_single_cell_experiment()}, \code{get_seurat()}, and
    \code{get_pseudobulk()}.
    \itemize{
        \item When \code{TRUE}, remote files are synchronised to
        \code{cache_directory} but are not read or assembled into an
        in-memory object.
        \item Quality-control filtering (\code{keep_quality_cells()}) is
        applied automatically in both modes, so only the files required for
        quality-controlled cells are downloaded. A warning is emitted when
        cells are excluded so users are informed even if they omit
        \code{keep_quality_cells()} explicitly.
        \item For the \code{sct} assay, the post-sync missing-file check
        (\code{.skip_groups_missing_sct_file()}) now runs before the
        \code{download_only} early return, so warnings about samples whose
        SCT normalisation failed are emitted regardless of mode.
        \item When \code{assays = "sct"} only and every sample is missing
        its SCT file, the function emits a warning and returns
        \code{invisible(NULL)} instead of aborting.
    }
}}

\section{News in version 0.99.31}{
\itemize{
    \item Added \code{donor_id} to harmonised metadata, enabling direct donor-level
    queries across datasets.
    \item Updated metadata parquet versions to \code{hca2024_v2.3.2}
    \item Expanded and corrected documentation for metadata columns on website.
    \item Removed internal columns (\code{sample_},
    \code{sample_heuristic}, \code{sample_chunk}, \code{cell_chunk}, 
    \code{sample_pseudobulk_chunk}) from documentation.
}}

\section{News in version 0.99.30}{
\itemize{
    \item \code{get_seurat()} now correctly handles multiple assays and non-default
    first assays.
    \itemize{
        \item When \code{assays = c("counts", "cpm")} (or any multi-assay request),
        all assays are transferred to the returned Seurat object: the first assay
        occupies the \code{"originalexp"} slot and every subsequent assay is added
        under its own name (e.g. \code{"cpm"}).
        \item When the first requested assay is not \code{"counts"} (e.g.
        \code{assays = "cpm"}), the conversion no longer errors with
        \emph{"No data in provided assay - counts"}. The first assay in the SCE is
        now passed explicitly to \code{SeuratObject::as.Seurat()}.
    }
    \item SCT assay: robust handling of samples for which SCT normalisation failed.
    \itemize{
        \item HTTP 404 responses for SCT h5ad files are now treated as
        \emph{"file not available"} rather than a fatal download error. The SCT
        sync path uses \code{ignore_not_found = TRUE} while all other assay syncs
        remain strict.
        \item A new internal helper \code{.skip_groups_missing_sct_file()} detects
        cached-file absence after sync, emits a \code{cellNexus says:} warning with
        the affected cell/sample counts and up to three example \code{sample_id}s,
        and instructs users to identify skipped samples post-retrieval via
        \code{dplyr::setdiff(unique(your_metadata\$sample_id),
        unique(SummarizedExperiment::colData(result)\$sample_id))}.
        \item When \code{assays = "sct"} only and \emph{every} sample is missing its
        SCT file, \code{get_single_cell_experiment()} aborts with a clear message.
        \item When \code{assays = c("counts", "sct")} (or any mixed-assay request)
        and \emph{every} sample is missing its SCT file, the function falls back
        gracefully to returning the non-SCT assays for all cells with a warning,
        rather than aborting.
    }
    \item Tests. Added coverage for \code{get_seurat()} multi-assay and
    non-default-assay paths.
}}

\section{News in version 0.99.27}{
\itemize{
    \item \code{get_pseudobulk()} now retains metadata columns that are constant within each
    \code{sample_id} x \code{cell_type_unified_ensemble} combination, including
    user-added annotations, when building \code{colData}. Cell-level columns are dropped.
    \item \code{get_metacell()} uses the same once-per-query column selection for
    \code{sample_id} x metacell-level annotations, so \code{cbind()} across
    files shares an identical \code{colData} schema.
    \item Added internal helpers \code{get_specific_annotation_columns()} and
    \code{keep_specific_annotation_columns()} to identify and keep columns functionally
    determined by selected key column(s). Works on local data frames and lazy DuckDB
    tables from \code{get_metadata()}.
    \item Tests. Added coverage for annotation-column detection and for preserving
    sample-grain user columns through \code{get_pseudobulk()}, using
    \code{SAMPLE_DATABASE_URL}.
}}

\section{News in version 0.99.10}{
\itemize{
    \item \code{get_pseudobulk()} gained \code{as_SummarizedExperiment} to optionally return a \code{SummarizedExperiment}. Coercion restores feature rownames, which are otherwise dropped by \code{as(x, "SummarizedExperiment")}.
    \item Tests. Added a test ensuring feature rownames are preserved when \code{as_SummarizedExperiment = TRUE}.
}}

\section{News in version 0.99.4}{
\itemize{
    \item Consistent features handling across retrieval functions. \code{get_pseudobulk()}, \code{get_single_cell_experiment()}, and \code{get_metacell()} now drop experiments/samples that do not contain all requested features and align rows to the requested feature set before merging. A warning indicates how many experiments were dropped.
    \item Stabilised feature subsetting during merge to avoid index/subscript errors and ensure identical row order across experiments prior to \code{cbind()}.
    \item Qualified functional calls (e.g., \code{purrr::map_lgl}) to avoid missing import issues.
    \item Documentation updates. Clarified the \code{features} parameter docs for all three functions to describe the drop-and-align behavior; regenerated help files.
    \item Tests. Added a test verifying pseudobulk subsetting to the specific feature \code{ENSG00000065485}.
}}

\section{News in version 0.1.0}{
\itemize{
    \item Added a NEWS file to track changes to the package.
}}
