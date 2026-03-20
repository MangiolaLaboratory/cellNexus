# Changelog

## cellNexus 0.99.12

- Replace deprecated
  [`dplyr::cur_data_all()`](https://dplyr.tidyverse.org/reference/deprec-context.html)
  (deprecated since dplyr 1.1.0) with a `purrr`-based iteration approach
  using
  [`group_split()`](https://dplyr.tidyverse.org/reference/group_split.html)
  and `map()`, eliminating the deprecation warning when calling
  [`get_single_cell_experiment()`](https://mangiolalaboratory.github.io/cellNexus/reference/get_single_cell_experiment.md),
  [`get_pseudobulk()`](https://mangiolalaboratory.github.io/cellNexus/reference/get_pseudobulk.md),
  and related functions
  ([\#92](https://github.com/MangiolaLaboratory/cellNexus/issues/92)).

## cellNexus 0.99.8

- Initial CRAN submission.
