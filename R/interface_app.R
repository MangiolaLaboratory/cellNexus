#' Parse a string delimited by commas, whitespace, or new lines to a vector.
#'
#' Used to parse text inputs into a vector.
#'
#' @param x A string of elements delimited by comma, whitespace, or new lines,
#'   e.g. "a, b c,d, e".
#'
#' @return A vector of strings like `c("a", "b", "c", "d", "e")`.
#'   If the input is "", just returns "". If the input is `NULL`, returns `NULL`.
#'
#' @author Jared Andrews
#' @rdname INTERNAL_string_to_vector
.string_to_vector <- function(x) {
    if (!is.null(x)) {
        if (x != "") {
            # Split string to vector based on commas, whitespace, or new lines
            x <- strsplit(x, ",|\\s|,\\s")[[1]]
        }
    }

    x
}


#' Organize arbitrary Shiny inputs into a grid layout
#' @param tag.list A tagList containing UI inputs or a named list
#'   containing multiple tagLists containing UI inputs.
#' @param title An optional title for the grid, should be a UI element,
#'   e.g. h3("Title").
#' @param tack An optional UI input to tack onto the end of the grid.
#' @param columns Number of columns.
#' @param rows Number of rows.
#' @param id An optional ID for the tabsetPanel if a named list is provided.
#'
#' @return A Shiny tagList with inputs organized into a grid, optionally
#'   nested inside a tabsetPanel.
#'
#' @importFrom shiny fluidRow column tagList tabsetPanel tabPanel
#' @export
#'
#' @author Jared Andrews
#' @examples
#' library(shiny)
#' # Example 1: Basic usage with a simple grid
#' ui.inputs <- tagList(
#'     textInput("name", "Name"),
#'     numericInput("age", "Age", value = 30),
#'     selectInput("gender", "Gender", choices = c("Male", "Female", "Other"))
#' )
#' organize_inputs(ui.inputs, columns = 2, rows = 2)
#'
#' # Example 2: Using a named list to create tabs
#' ui.inputs.tabs <- list(
#'     Personal = tagList(
#'         textInput("firstname", "First Name"),
#'         textInput("lastname", "Last Name")
#'     ),
#'     Settings = tagList(
#'         checkboxInput("newsletter", "Subscribe to newsletter", value = TRUE),
#'         sliderInput("volume", "Volume", min = 0, max = 100, value = 50)
#'     )
#' )
#' organize_inputs(ui.inputs.tabs, columns = 2)
#'
#' # Example 3: Adding an additional UI element with 'tack'
#' additional.ui <- actionButton("submit", "Submit")
#' organize_inputs(ui.inputs, tack = additional.ui, columns = 3)
#'
#' # Example 4: Handling a case with more inputs than grid cells
#' many.inputs <- tagList(replicate(10, textInput("input", "Input")))
#' organize_inputs(many.inputs, columns = 3) # Creates more than one row
organize_inputs <- function(
    tag.list,
    id = NULL,
    title = NULL,
    tack = NULL,
    columns = NULL,
    rows = NULL) {
    # Check if tag.list is a list of named lists
    if (!is(tag.list, "shiny.tag.list")) {
        # Create a tabsetPanel with a tabPanel for each list element
        tabs <- c(
            lapply(names(tag.list), function(tab.name) {
                tabPanel(
                    tab.name,
                    do.call(tagList, organize_inputs(tag.list[[tab.name]], columns = columns, rows = rows))
                )
            })
        )

        if (!is.null(id)) {
            tabs[["id"]] <- id
        }

        out <- do.call(tabsetPanel, tabs)

    } else {
        n.tags <- length(tag.list)

        # Calculate missing dimension based on the provided one and total tags
        if (is.null(columns) & !is.null(rows)) {
            columns <- ceiling(n.tags / rows)
        } else if (is.null(rows) & !is.null(columns)) {
            rows <- ceiling(n.tags / columns)
        } else if (is.null(rows) & is.null(columns)) {
            stop("Either rows or columns must be provided.")
        }

        out <- lapply(seq_len(rows), function(r) {
            do.call(fluidRow, lapply(seq_len(columns), function(c) {
                idx <- (r - 1) * columns + c
                if (idx <= n.tags) {
                    column(width = 12 / columns, tag.list[[idx]])
                }
            }))
        })
    }

    if (!is.null(tack)) {
        out <- tagList(out, tack)
    }

    if (!is.null(title)) {
        out <- tagList(title, out)
    }

    out
}


#' Create a Shiny app that allows users to generate filtering & retreival code for cellNexus
#'
#' @param ui_choices A list of pre-computed unique values for each filterable column in the metadata.
#' @return A Shiny app that allows users to filter cellNexus metadata and generate code for retrieval
#'   in the selected format.
#'
#' @importFrom shiny fluidPage sidebarLayout sidebarPanel mainPanel titlePanel textAreaInput
#'   verbatimTextOutput renderPrint shinyApp h3 tagList reactiveValues selectInput hr tabsetPanel tabPanel
#' @importFrom shinyWidgets pickerInput pickerOptions
#' @importFrom dplyr filter distinct
#'
#' @examples
#' \dontrun{
#' library(cellNexus)
#' app <- create_interface_app(ui_choices)
#' shiny::runApp(app)
#' }
#' @export
#' @author Jared Andrews
create_interface_app <- function(ui_choices) {
    # Load pre-computed UI choices from package data
    # These choices are generated by inst/app/generate_ui_choices.R
    all_choices <- ui_choices

    # Column definitions for cell-related filters
    cell_cols <- c(
        "cell_type_unified_ensemble",
        "cell_type",
        "alive",
        "scDblFinder.class",
        "is_immune",
        "empty_droplet"
    )

    # Extract cell choices from pre-computed choices
    cell_choices <- all_choices[cell_cols]
    names(cell_choices) <- cell_cols

    # Column definitions for sample-related filters
    sample_cols <- c(
        "development_stage",
        "disease",
        "self_reported_ethnicity",
        "sex",
        # "age_days",
        "tissue",
        "tissue_groups"
    )

    # Extract sample choices from pre-computed choices
    sample_choices <- all_choices[sample_cols]
    names(sample_choices) <- sample_cols

    cell_inputs <- lapply(cell_cols, function(col) {
        choices <- cell_choices[[col]]
        pickerInput(
            inputId = col,
            label = col,
            choices = choices,
            multiple = TRUE,
            selected = choices,
            options = pickerOptions(
                actionsBox = TRUE,
                liveSearch = TRUE,
                selectedTextFormat = "count > 3",
                size = 20
            )
        )
    })

    sample_inputs <- lapply(sample_cols, function(col) {
        choices <- sample_choices[[col]]
        pickerInput(
            inputId = col,
            label = col,
            choices = choices,
            multiple = TRUE,
            selected = choices,
            options = pickerOptions(
                actionsBox = TRUE,
                liveSearch = TRUE,
                selectedTextFormat = "count > 3",
                size = 20
            )
        )
    })

    class(cell_inputs) <- c("shiny.tag.list", "list")
    class(sample_inputs) <- c("shiny.tag.list", "list")

    # Retrieval options
    retrieval_inputs <- tagList(
        textAreaInput(
            inputId = "features",
            label = "Features",
            placeholder = "Enter feature IDs separated by commas, whitespace, or new lines.",
            rows = 3
        ),
        selectInput(
            inputId = "retrieval_type",
            label = "Output Type",
            choices = c("SingleCellExperiment", "pseudobulk", "Seurat", "metacell"),
            selected = "SingleCellExperiment"
        ),
        selectInput(
            inputId = "assay",
            label = "Assay",
            choices = c("counts", "cpm"),
            selected = "counts"
        ),
        selectInput(
            inputId = "metacell_aggregation",
            label = "Metacell Aggregation",
            choices = c("metacell_2", "metacell_4", "metacell_8", "metacell_16",
                "metacell_32", "metacell_64", "metacell_128", "metacell_256",
                "metacell_512", "metacell_1024", "metacell_2048", "metacell_4096",
                "metacell_8192"),
            selected = "metacell_2"
        ),
    )

    ui <- fluidPage(
        titlePanel("cellNexus Data Selection"),
        sidebarLayout(
            sidebarPanel(width = 5,
                organize_inputs(cell_inputs, columns = 2, title = h3("Cell Type")),
                hr(),
                organize_inputs(sample_inputs, columns = 3, title = h3("Sample")),
                hr(),
                organize_inputs(retrieval_inputs, columns = 2, title = h3("Retrieval Options")),
            ),
            mainPanel(width = 7,
                h3("Generated Code"),
                tabsetPanel(
                    tabPanel("R", verbatimTextOutput("r_code_box")),
                    tabPanel("Python", verbatimTextOutput("python_code_box"))
                )
            )
        )
    )

    server <- function(input, output, session) {

        # Observe the features input and update the features reactive value
        features <- reactive({
            # Parse the features input into a vector
            .string_to_vector(input$features)
        })

        full_code <- reactive({
            filter_conditions <- list()

            # Add filters to filter_conditions from input_filters()
            input_list <- input_filters()
            if (!is.null(input_list)) {
                for (i in seq_along(input_list)) {
                    input_id <- names(input_list)[i]
                    input_val <- input_list[[i]]

                    condition <- paste0(input_id, " %in% c(", paste(shQuote(input_val), collapse = ", "), ")")
                    filter_conditions <- c(filter_conditions, condition)
                }
            }

            code_lines <- c("library(cellNexus)", "my_data <- get_metadata() |>",
                if (length(filter_conditions) > 0) {
                    paste0("  dplyr::filter(", paste(filter_conditions, collapse = ",\n         "), ") |>")
                },
                retrieval_condition()
            )

            cat(paste(code_lines, collapse = "\n"))
        })

        # Collect inputs as data.frame with each row as input_id and filter
        # Only include inputs that are not NULL, "", or with all values selected
        input_filters <- reactive({
            input_list <- list()
            df_row <- NULL
            all_cols <- c(cell_cols, sample_cols)
            all_choices <- c(cell_choices, sample_choices)
            for(i in c(all_cols)) {
                curr_input <- input[[i]]
                # Check if the input is NULL or empty
                is_def_choices <- length(curr_input) == length(all_choices[[i]])
                if (length(curr_input) == 0 || all(curr_input == "") || is_def_choices) {
                    next
                }

                input_list[[i]] <- curr_input
            }

            input_list
        })

        # Observe the retrieval type input and update the retrieval type reactive value
        retrieval_condition <- reactive({
            if (input$retrieval_type == "SingleCellExperiment") {
                paste0("get_single_cell_experiment(",
                    if (length(features()) > 1 || all(features() != "")) {
                        paste0("features = c(", paste0(shQuote(features()), collapse = ", "), "), ")
                    },
                    "assays = ", shQuote(input$assay), ")")
            } else if (input$retrieval_type == "pseudobulk") {
                paste0("get_pseudobulk(",
                    if (length(features()) > 1 || all(features() != "")) {
                        paste0("features = c(", paste0(shQuote(features()), collapse = ", "), "), ")
                    },
                    "assays = ", shQuote(input$assay), ")")
            } else if (input$retrieval_type == "Seurat") {
                paste0("get_seurat(",
                    if (length(features()) > 1 || all(features() != "")) {
                        paste0("features = c(", paste0(shQuote(features()), collapse = ", "), "), ")
                    },
                    "assays = ", shQuote(input$assay), ")")
            } else if (input$retrieval_type == "metacell") {
                paste0("dplyr::filter(!is.na(", input$metacell_aggregation, ")) |> \nget_metacell(",
                    if (length(features()) > 1 || all(features() != "")) {
                        paste0("features = c(", paste0(shQuote(features()), collapse = ", "), "), ")
                    },
                    "assays = ", shQuote(input$assay), ", cell_aggregation = ", shQuote(input$metacell_aggregation), ")")
            }
        })

        # Generate Python code for cellnexuspy
        python_full_code <- reactive({
            filter_conditions <- list()

            # Add filters to filter_conditions from input_filters()
            input_list <- input_filters()
            if (!is.null(input_list)) {
                for (i in seq_along(input_list)) {
                    input_id <- names(input_list)[i]
                    input_val <- input_list[[i]]

                    # Format values for Python - handle logical values
                    if (is.logical(input_val)) {
                        py_vals <- ifelse(input_val, "True", "False")
                    } else {
                        py_vals <- paste0("'", input_val, "'")
                    }

                    if (length(input_val) == 1) {
                        condition <- paste0(input_id, " == ", py_vals)
                    } else {
                        condition <- paste0(input_id, " IN (", paste(py_vals, collapse = ", "), ")")
                    }
                    filter_conditions <- c(filter_conditions, condition)
                }
            }

            # Build the Python code
            code_lines <- c(
                "from cellnexuspy import get_metadata, get_anndata",
                "",
                "# Connect to metadata",
                "conn, table = get_metadata()",
                ""
            )

            # Add filter if conditions exist
            if (length(filter_conditions) > 0) {
                filter_str <- paste(filter_conditions, collapse = " AND ")
                code_lines <- c(code_lines,
                    "# Apply filters",
                    paste0('query = table.filter("', filter_str, '")'),
                    ""
                )
            } else {
                code_lines <- c(code_lines,
                    "# No filters applied",
                    "query = table",
                    ""
                )
            }

            # Add retrieval code
            code_lines <- c(code_lines,
                "# Retrieve data",
                python_retrieval_condition(),
                "",
                "# Close connection when finished",
                "conn.close()"
            )

            cat(paste(code_lines, collapse = "\n"))
        })

        # Python retrieval condition
        python_retrieval_condition <- reactive({
            # Build features argument if specified
            features_arg <- ""
            if (length(features()) > 1 || all(features() != "")) {
                py_features <- paste0("'", features(), "'", collapse = ", ")
                features_arg <- paste0(", features=[", py_features, "]")
            }

            if (input$retrieval_type == "SingleCellExperiment") {
                paste0("adata = get_anndata(query, assay='", input$assay, "'", features_arg, ")")
            } else if (input$retrieval_type == "pseudobulk") {
                paste0("adata = get_anndata(query, aggregation='pseudobulk', assay='", input$assay, "'", features_arg, ")")
            } else if (input$retrieval_type == "Seurat") {
                # Seurat is R-specific, just return AnnData for Python
                paste0("adata = get_anndata(query, assay='", input$assay, "'", features_arg, ")  # Note: Seurat is R-specific; returning AnnData")
            } else if (input$retrieval_type == "metacell") {
                paste0("adata = get_anndata(query, aggregation='", input$metacell_aggregation, "', assay='", input$assay, "'", features_arg, ")")
            }
        })

        output$r_code_box <- renderPrint({
            full_code()
        })

        output$python_code_box <- renderPrint({
            python_full_code()
        })
    }

    shinyApp(ui, server)
}
