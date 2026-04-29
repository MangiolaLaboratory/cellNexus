# Pre-compute all vignettes and regenerate derived outputs.
#
# Run this script whenever any .Rmd.orig file is updated (e.g. before a
# release). It executes all code once and produces:
#
#   vignettes/cellNexus.Rmd             — pre-computed main vignette
#   vignettes/cellNexus.html            — HTML version of the above
#   README.md                           — GitHub-flavoured markdown
#   vignettes/gene-expression-explore.Rmd  — pre-computed article vignette
#   vignettes/metadata-explore.Rmd         — pre-computed article vignette
#
# Usage (from the package root):
#   source("vignettes/precompile.R")

proj_root <- rprojroot::find_package_root_file() |>
  normalizePath()
vig_dir <- file.path(proj_root, "vignettes")

# Pre-compute cellNexus.Rmd.
# knitr executes all code chunks and embeds the output as static markdown,
# so the resulting .Rmd contains no executable R code.
# Chunk wd = vignettes/: plot files land next to the .Rmd (portable paths),
# include_graphics uses ../man/figures/ so R CMD build finds man/ from vignettes/.
knitr::opts_knit$set(
  root.dir = vig_dir,
  unnormalized.path = TRUE
)
knitr::knit("vignettes/cellNexus.Rmd.orig", "vignettes/cellNexus.Rmd")
knitr::opts_knit$set(root.dir = NULL, unnormalized.path = NULL)

# README.md lives at repo root: rewrite vignette-relative paths after render.
rewrite_readme_paths <- function(readme_path) {
  x <- readLines(readme_path, warn = FALSE, encoding = "UTF-8")
  x <- gsub("\\.\\./man/figures/", "man/figures/", x)
  x <- gsub("(\\]\\(|src=\")plot-fcn1-disease-1\\.png", "\\1vignettes/plot-fcn1-disease-1.png", x)
  x <- gsub("(\\]\\(|src=\")plot-fcn1-tissue-1\\.png", "\\1vignettes/plot-fcn1-tissue-1.png", x)
  writeLines(x, readme_path, useBytes = FALSE)
}

# Render HTML vignette from the pre-computed file.
rmarkdown::render(
  "vignettes/cellNexus.Rmd",
  knit_root_dir = vig_dir,
  output_format = BiocStyle::html_document(
    toc = TRUE,
    toc_float = TRUE
  )
)

# Render README.md from the pre-computed file.
rmarkdown::render(
  "vignettes/cellNexus.Rmd",
  output_file    = "README.md",
  output_format  = "github_document",
  output_dir     = proj_root,
  knit_root_dir  = vig_dir
)
rewrite_readme_paths(file.path(proj_root, "README.md"))

# Article vignettes
knitr::knit("vignettes/gene-expression-explore.Rmd.orig", "vignettes/gene-expression-explore.Rmd")
knitr::knit("vignettes/metadata-explore.Rmd.orig", "vignettes/metadata-explore.Rmd")
