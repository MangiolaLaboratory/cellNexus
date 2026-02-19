# Parse a string delimited by commas, whitespace, or new lines to a vector.

Used to parse text inputs into a vector.

## Usage

``` r
.string_to_vector(x)
```

## Arguments

- x:

  A string of elements delimited by comma, whitespace, or new lines,
  e.g. "a, b c,d, e".

## Value

A vector of strings like `c("a", "b", "c", "d", "e")`. If the input is
"", just returns "". If the input is `NULL`, returns `NULL`.

## Author

Jared Andrews
