# cellNexus 0.99.12

* Replace deprecated `dplyr::cur_data_all()` (deprecated since dplyr 1.1.0) with
  a `purrr`-based iteration approach using `group_split()` and `map()`, eliminating
  the deprecation warning when calling `get_single_cell_experiment()`,
  `get_pseudobulk()`, and related functions. The same modernisation is applied to
  `get_unharmonised_metadata()` for consistency (#92).

# cellNexus 0.99.8

* Initial CRAN submission.
