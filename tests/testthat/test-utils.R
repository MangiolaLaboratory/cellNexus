test_that("url_file_size() returns the correct sizes", {
    c(
        "https://ftp.ncbi.nlm.nih.gov/refseq/H_sapiens/annotation/GRCh38_latest/refseq_identifiers/GRCh38_latest_genomic.fna.gz",
        "https://ftp.ncbi.nlm.nih.gov/refseq/H_sapiens/annotation/GRCh37_latest/refseq_identifiers/GRCh37_latest_genomic.fna.gz"
    ) |>
        url_file_size() |>
        expect_equal(c(
            0.973,
            0.944
        ), tolerance = 0.001)
})

test_that("get_default_cache_dir() returns a character path", {
  d <- get_default_cache_dir()
  expect_type(d, "character")
  expect_length(d, 1L)
  expect_true(nzchar(d))
  expect_true(grepl("cellNexus", d, fixed = TRUE))
})

test_that("clear_old_metadata() runs without error", {
  expect_invisible(cellNexus:::clear_old_metadata("sample_metadata.2.0.0.parquet"))
})
