# Organize arbitrary Shiny inputs into a grid layout

Organize arbitrary Shiny inputs into a grid layout

## Usage

``` r
organize_inputs(
  tag.list,
  id = NULL,
  title = NULL,
  tack = NULL,
  columns = NULL,
  rows = NULL
)
```

## Arguments

- tag.list:

  A tagList containing UI inputs or a named list containing multiple
  tagLists containing UI inputs.

- id:

  An optional ID for the tabsetPanel if a named list is provided.

- title:

  An optional title for the grid, should be a UI element, e.g.
  h3("Title").

- tack:

  An optional UI input to tack onto the end of the grid.

- columns:

  Number of columns.

- rows:

  Number of rows.

## Value

A Shiny tagList with inputs organized into a grid, optionally nested
inside a tabsetPanel.

## Author

Jared Andrews

## Examples

``` r
library(shiny)
#> Warning: package ‘shiny’ was built under R version 4.5.1
# Example 1: Basic usage with a simple grid
ui.inputs <- tagList(
    textInput("name", "Name"),
    numericInput("age", "Age", value = 30),
    selectInput("gender", "Gender", choices = c("Male", "Female", "Other"))
)
organize_inputs(ui.inputs, columns = 2, rows = 2)
#> [[1]]
#> <div class="row">
#>   <div class="col-sm-6">
#>     <div class="form-group shiny-input-container">
#>       <label class="control-label" id="name-label" for="name">Name</label>
#>       <input id="name" type="text" class="shiny-input-text form-control" value="" data-update-on="change"/>
#>     </div>
#>   </div>
#>   <div class="col-sm-6">
#>     <div class="form-group shiny-input-container">
#>       <label class="control-label" id="age-label" for="age">Age</label>
#>       <input id="age" type="number" class="shiny-input-number form-control" value="30" data-update-on="change"/>
#>     </div>
#>   </div>
#> </div>
#> 
#> [[2]]
#> <div class="row">
#>   <div class="col-sm-6">
#>     <div class="form-group shiny-input-container">
#>       <label class="control-label" id="gender-label" for="gender">Gender</label>
#>       <div>
#>         <select id="gender" class="shiny-input-select"><option value="Male" selected>Male</option>
#> <option value="Female">Female</option>
#> <option value="Other">Other</option></select>
#>         <script type="application/json" data-for="gender" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
#>       </div>
#>     </div>
#>   </div>
#> </div>
#> 

# Example 2: Using a named list to create tabs
ui.inputs.tabs <- list(
    Personal = tagList(
        textInput("firstname", "First Name"),
        textInput("lastname", "Last Name")
    ),
    Settings = tagList(
        checkboxInput("newsletter", "Subscribe to newsletter", value = TRUE),
        sliderInput("volume", "Volume", min = 0, max = 100, value = 50)
    )
)
organize_inputs(ui.inputs.tabs, columns = 2)
#> <div class="tabbable">
#>   <ul class="nav nav-tabs" data-tabsetid="3444">
#>     <li class="active">
#>       <a href="#tab-3444-1" data-toggle="tab" data-bs-toggle="tab" data-value="Personal">Personal</a>
#>     </li>
#>     <li>
#>       <a href="#tab-3444-2" data-toggle="tab" data-bs-toggle="tab" data-value="Settings">Settings</a>
#>     </li>
#>   </ul>
#>   <div class="tab-content" data-tabsetid="3444">
#>     <div class="tab-pane active" data-value="Personal" id="tab-3444-1">
#>       <div class="row">
#>         <div class="col-sm-6">
#>           <div class="form-group shiny-input-container">
#>             <label class="control-label" id="firstname-label" for="firstname">First Name</label>
#>             <input id="firstname" type="text" class="shiny-input-text form-control" value="" data-update-on="change"/>
#>           </div>
#>         </div>
#>         <div class="col-sm-6">
#>           <div class="form-group shiny-input-container">
#>             <label class="control-label" id="lastname-label" for="lastname">Last Name</label>
#>             <input id="lastname" type="text" class="shiny-input-text form-control" value="" data-update-on="change"/>
#>           </div>
#>         </div>
#>       </div>
#>     </div>
#>     <div class="tab-pane" data-value="Settings" id="tab-3444-2">
#>       <div class="row">
#>         <div class="col-sm-6">
#>           <div class="form-group shiny-input-container">
#>             <div class="checkbox">
#>               <label>
#>                 <input id="newsletter" type="checkbox" class="shiny-input-checkbox" checked="checked"/>
#>                 <span>Subscribe to newsletter</span>
#>               </label>
#>             </div>
#>           </div>
#>         </div>
#>         <div class="col-sm-6">
#>           <div class="form-group shiny-input-container">
#>             <label class="control-label" id="volume-label" for="volume">Volume</label>
#>             <input class="js-range-slider" id="volume" data-skin="shiny" data-min="0" data-max="100" data-from="50" data-step="1" data-grid="true" data-grid-num="10" data-grid-snap="false" data-prettify-separator="," data-prettify-enabled="true" data-keyboard="true" data-data-type="number"/>
#>           </div>
#>         </div>
#>       </div>
#>     </div>
#>   </div>
#> </div>

# Example 3: Adding an additional UI element with 'tack'
additional.ui <- actionButton("submit", "Submit")
organize_inputs(ui.inputs, tack = additional.ui, columns = 3)
#> <div class="row">
#>   <div class="col-sm-4">
#>     <div class="form-group shiny-input-container">
#>       <label class="control-label" id="name-label" for="name">Name</label>
#>       <input id="name" type="text" class="shiny-input-text form-control" value="" data-update-on="change"/>
#>     </div>
#>   </div>
#>   <div class="col-sm-4">
#>     <div class="form-group shiny-input-container">
#>       <label class="control-label" id="age-label" for="age">Age</label>
#>       <input id="age" type="number" class="shiny-input-number form-control" value="30" data-update-on="change"/>
#>     </div>
#>   </div>
#>   <div class="col-sm-4">
#>     <div class="form-group shiny-input-container">
#>       <label class="control-label" id="gender-label" for="gender">Gender</label>
#>       <div>
#>         <select id="gender" class="shiny-input-select"><option value="Male" selected>Male</option>
#> <option value="Female">Female</option>
#> <option value="Other">Other</option></select>
#>         <script type="application/json" data-for="gender" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
#>       </div>
#>     </div>
#>   </div>
#> </div>
#> <button id="submit" type="button" class="btn btn-default action-button">
#>   <span class="action-label">Submit</span>
#> </button>

# Example 4: Handling a case with more inputs than grid cells
many.inputs <- tagList(replicate(10, textInput("input", "Input")))
organize_inputs(many.inputs, columns = 3) # Creates more than one row
#> [[1]]
#> <div class="row">
#>   <div class="col-sm-4">
#>     div
#>     form-group shiny-input-container
#>     <label class="control-label" id="input-label" for="input">Input</label>
#>     <input id="input" type="text" class="shiny-input-text form-control" value="" data-update-on="change"/>
#>     div
#>     form-group shiny-input-container
#>     <label class="control-label" id="input-label" for="input">Input</label>
#>     <input id="input" type="text" class="shiny-input-text form-control" value="" data-update-on="change"/>
#>     div
#>     form-group shiny-input-container
#>     <label class="control-label" id="input-label" for="input">Input</label>
#>     <input id="input" type="text" class="shiny-input-text form-control" value="" data-update-on="change"/>
#>     div
#>     form-group shiny-input-container
#>     <label class="control-label" id="input-label" for="input">Input</label>
#>     <input id="input" type="text" class="shiny-input-text form-control" value="" data-update-on="change"/>
#>     div
#>     form-group shiny-input-container
#>     <label class="control-label" id="input-label" for="input">Input</label>
#>     <input id="input" type="text" class="shiny-input-text form-control" value="" data-update-on="change"/>
#>     div
#>     form-group shiny-input-container
#>     <label class="control-label" id="input-label" for="input">Input</label>
#>     <input id="input" type="text" class="shiny-input-text form-control" value="" data-update-on="change"/>
#>     div
#>     form-group shiny-input-container
#>     <label class="control-label" id="input-label" for="input">Input</label>
#>     <input id="input" type="text" class="shiny-input-text form-control" value="" data-update-on="change"/>
#>     div
#>     form-group shiny-input-container
#>     <label class="control-label" id="input-label" for="input">Input</label>
#>     <input id="input" type="text" class="shiny-input-text form-control" value="" data-update-on="change"/>
#>     div
#>     form-group shiny-input-container
#>     <label class="control-label" id="input-label" for="input">Input</label>
#>     <input id="input" type="text" class="shiny-input-text form-control" value="" data-update-on="change"/>
#>     div
#>     form-group shiny-input-container
#>     <label class="control-label" id="input-label" for="input">Input</label>
#>     <input id="input" type="text" class="shiny-input-text form-control" value="" data-update-on="change"/>
#>   </div>
#> </div>
#> 
```
