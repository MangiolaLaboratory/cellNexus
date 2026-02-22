# Script to generate pre-computed UI choices for the cellNexus interface app
#
# This script queries the full metadata to extract unique values for each
# filterable column used in the Shiny interface. The choices are saved to an
# RDS file that can be loaded quickly by the app, avoiding the slow initial
# metadata query.
#
# Usage:
#   From the package root directory, run:
#   Rscript inst/app/generate_ui_choices.R
#
# Output:
#   inst/app/ui_choices.rds - A list containing unique values for each column

library(dplyr)
library(rlang)

devtools::load_all()
metadata <- get_metadata()

cell_cols <- c(
    "cell_type_unified_ensemble",
    "cell_type",
    "alive",
    "scDblFinder.class",
    "is_immune",
    "empty_droplet"
)

sample_cols <- c(
    "development_stage",
    "disease",
    "self_reported_ethnicity",
    "sex",
    "tissue",
    "tissue_groups"
)

all_cols <- c(cell_cols, sample_cols)

# Extract unique values for each column
choices <- list()

for (col in all_cols) {
    message(sprintf("  Processing %s...", col))
    tryCatch({
        unique_vals <- metadata |>
            distinct(!!sym(col)) |>
            collect() |>
            pull(!!sym(col))
        
        # Sort values for better UX (NA values should go last)
        unique_vals <- sort(unique_vals, na.last = TRUE)
        
        # For logical columns, ensure we have proper TRUE/FALSE values
        if (is.logical(unique_vals)) {
            unique_vals <- c(TRUE, FALSE)
        }
        
        choices[[col]] <- unique_vals
        message(sprintf("    Found %d unique values", length(unique_vals)))
    }, error = function(e) {
        warning(sprintf("Failed to get choices for %s: %s", col, e$message))
        choices[[col]] <- character(0)
    })
}

# Save the choices to an RDS file
output_path <- file.path("inst", "app", "ui_choices.rds")
saveRDS(choices, output_path)

for (col in names(choices)) {
    message(sprintf("  %s: %d unique values", col, length(choices[[col]])))
}
