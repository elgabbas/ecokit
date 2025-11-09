# Split a data.frame into smaller chunks

This function divides a data.frame into smaller chunks based on the
specified number of rows per chunk (`chunk_size`) or the specified
number of chunks (`n_chunks`). If neither is provided, it defaults to
splitting the data.frame into a minimum of 5 chunks or less if the
data.frame has fewer than 5 rows. The function ensures that the data is
evenly distributed among the chunks as much as possible.

## Usage

``` r
split_df_to_chunks(
  data = NULL,
  chunk_size = NULL,
  n_chunks = NULL,
  prefix = "Chunk"
)
```

## Arguments

- data:

  `data.frame`. The data.frame to be split into chunks.

- chunk_size:

  Integer. Number of rows each chunk should contain. It must be a
  positive integer and less than the number of rows in `data`.

- n_chunks:

  Integer. Number of chunks to split the data.frame into. It must be a
  positive integer.

- prefix:

  Character. Prefix for the names of the chunks. Default is "Chunk".

## Value

A list of data.frames, where each data.frame represents a chunk of the
original data.frame. The names of the list elements are constructed
using the `prefix` parameter followed by an underscore and the chunk
number (e.g., "Chunk_1", "Chunk_2", ...).

## Author

Ahmed El-Gabbas

## Examples

``` r
split_df_to_chunks(mtcars, chunk_size = 16)
#> $Chunk_1
#> # A tibble: 16 × 11
#>      mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
#>    <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#>  1  21       6  160    110  3.9   2.62  16.5     0     1     4     4
#>  2  21       6  160    110  3.9   2.88  17.0     0     1     4     4
#>  3  22.8     4  108     93  3.85  2.32  18.6     1     1     4     1
#>  4  21.4     6  258    110  3.08  3.22  19.4     1     0     3     1
#>  5  18.7     8  360    175  3.15  3.44  17.0     0     0     3     2
#>  6  18.1     6  225    105  2.76  3.46  20.2     1     0     3     1
#>  7  14.3     8  360    245  3.21  3.57  15.8     0     0     3     4
#>  8  24.4     4  147.    62  3.69  3.19  20       1     0     4     2
#>  9  22.8     4  141.    95  3.92  3.15  22.9     1     0     4     2
#> 10  19.2     6  168.   123  3.92  3.44  18.3     1     0     4     4
#> 11  17.8     6  168.   123  3.92  3.44  18.9     1     0     4     4
#> 12  16.4     8  276.   180  3.07  4.07  17.4     0     0     3     3
#> 13  17.3     8  276.   180  3.07  3.73  17.6     0     0     3     3
#> 14  15.2     8  276.   180  3.07  3.78  18       0     0     3     3
#> 15  10.4     8  472    205  2.93  5.25  18.0     0     0     3     4
#> 16  10.4     8  460    215  3     5.42  17.8     0     0     3     4
#> 
#> $Chunk_2
#> # A tibble: 16 × 11
#>      mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
#>    <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#>  1  14.7     8 440     230  3.23  5.34  17.4     0     0     3     4
#>  2  32.4     4  78.7    66  4.08  2.2   19.5     1     1     4     1
#>  3  30.4     4  75.7    52  4.93  1.62  18.5     1     1     4     2
#>  4  33.9     4  71.1    65  4.22  1.84  19.9     1     1     4     1
#>  5  21.5     4 120.     97  3.7   2.46  20.0     1     0     3     1
#>  6  15.5     8 318     150  2.76  3.52  16.9     0     0     3     2
#>  7  15.2     8 304     150  3.15  3.44  17.3     0     0     3     2
#>  8  13.3     8 350     245  3.73  3.84  15.4     0     0     3     4
#>  9  19.2     8 400     175  3.08  3.84  17.0     0     0     3     2
#> 10  27.3     4  79      66  4.08  1.94  18.9     1     1     4     1
#> 11  26       4 120.     91  4.43  2.14  16.7     0     1     5     2
#> 12  30.4     4  95.1   113  3.77  1.51  16.9     1     1     5     2
#> 13  15.8     8 351     264  4.22  3.17  14.5     0     1     5     4
#> 14  19.7     6 145     175  3.62  2.77  15.5     0     1     5     6
#> 15  15       8 301     335  3.54  3.57  14.6     0     1     5     8
#> 16  21.4     4 121     109  4.11  2.78  18.6     1     1     4     2
#> 

# -------------------------------------------

split_df_to_chunks(mtcars, n_chunks = 3)
#> $Chunk_1
#> # A tibble: 11 × 11
#>      mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
#>    <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#>  1  21       6  160    110  3.9   2.62  16.5     0     1     4     4
#>  2  21       6  160    110  3.9   2.88  17.0     0     1     4     4
#>  3  22.8     4  108     93  3.85  2.32  18.6     1     1     4     1
#>  4  21.4     6  258    110  3.08  3.22  19.4     1     0     3     1
#>  5  18.7     8  360    175  3.15  3.44  17.0     0     0     3     2
#>  6  18.1     6  225    105  2.76  3.46  20.2     1     0     3     1
#>  7  14.3     8  360    245  3.21  3.57  15.8     0     0     3     4
#>  8  24.4     4  147.    62  3.69  3.19  20       1     0     4     2
#>  9  22.8     4  141.    95  3.92  3.15  22.9     1     0     4     2
#> 10  19.2     6  168.   123  3.92  3.44  18.3     1     0     4     4
#> 11  17.8     6  168.   123  3.92  3.44  18.9     1     0     4     4
#> 
#> $Chunk_2
#> # A tibble: 11 × 11
#>      mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
#>    <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#>  1  16.4     8 276.    180  3.07  4.07  17.4     0     0     3     3
#>  2  17.3     8 276.    180  3.07  3.73  17.6     0     0     3     3
#>  3  15.2     8 276.    180  3.07  3.78  18       0     0     3     3
#>  4  10.4     8 472     205  2.93  5.25  18.0     0     0     3     4
#>  5  10.4     8 460     215  3     5.42  17.8     0     0     3     4
#>  6  14.7     8 440     230  3.23  5.34  17.4     0     0     3     4
#>  7  32.4     4  78.7    66  4.08  2.2   19.5     1     1     4     1
#>  8  30.4     4  75.7    52  4.93  1.62  18.5     1     1     4     2
#>  9  33.9     4  71.1    65  4.22  1.84  19.9     1     1     4     1
#> 10  21.5     4 120.     97  3.7   2.46  20.0     1     0     3     1
#> 11  15.5     8 318     150  2.76  3.52  16.9     0     0     3     2
#> 
#> $Chunk_3
#> # A tibble: 10 × 11
#>      mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
#>    <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#>  1  15.2     8 304     150  3.15  3.44  17.3     0     0     3     2
#>  2  13.3     8 350     245  3.73  3.84  15.4     0     0     3     4
#>  3  19.2     8 400     175  3.08  3.84  17.0     0     0     3     2
#>  4  27.3     4  79      66  4.08  1.94  18.9     1     1     4     1
#>  5  26       4 120.     91  4.43  2.14  16.7     0     1     5     2
#>  6  30.4     4  95.1   113  3.77  1.51  16.9     1     1     5     2
#>  7  15.8     8 351     264  4.22  3.17  14.5     0     1     5     4
#>  8  19.7     6 145     175  3.62  2.77  15.5     0     1     5     6
#>  9  15       8 301     335  3.54  3.57  14.6     0     1     5     8
#> 10  21.4     4 121     109  4.11  2.78  18.6     1     1     4     2
#> 

# -------------------------------------------

split_df_to_chunks(mtcars, n_chunks = 3, prefix = "T")
#> $T_1
#> # A tibble: 11 × 11
#>      mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
#>    <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#>  1  21       6  160    110  3.9   2.62  16.5     0     1     4     4
#>  2  21       6  160    110  3.9   2.88  17.0     0     1     4     4
#>  3  22.8     4  108     93  3.85  2.32  18.6     1     1     4     1
#>  4  21.4     6  258    110  3.08  3.22  19.4     1     0     3     1
#>  5  18.7     8  360    175  3.15  3.44  17.0     0     0     3     2
#>  6  18.1     6  225    105  2.76  3.46  20.2     1     0     3     1
#>  7  14.3     8  360    245  3.21  3.57  15.8     0     0     3     4
#>  8  24.4     4  147.    62  3.69  3.19  20       1     0     4     2
#>  9  22.8     4  141.    95  3.92  3.15  22.9     1     0     4     2
#> 10  19.2     6  168.   123  3.92  3.44  18.3     1     0     4     4
#> 11  17.8     6  168.   123  3.92  3.44  18.9     1     0     4     4
#> 
#> $T_2
#> # A tibble: 11 × 11
#>      mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
#>    <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#>  1  16.4     8 276.    180  3.07  4.07  17.4     0     0     3     3
#>  2  17.3     8 276.    180  3.07  3.73  17.6     0     0     3     3
#>  3  15.2     8 276.    180  3.07  3.78  18       0     0     3     3
#>  4  10.4     8 472     205  2.93  5.25  18.0     0     0     3     4
#>  5  10.4     8 460     215  3     5.42  17.8     0     0     3     4
#>  6  14.7     8 440     230  3.23  5.34  17.4     0     0     3     4
#>  7  32.4     4  78.7    66  4.08  2.2   19.5     1     1     4     1
#>  8  30.4     4  75.7    52  4.93  1.62  18.5     1     1     4     2
#>  9  33.9     4  71.1    65  4.22  1.84  19.9     1     1     4     1
#> 10  21.5     4 120.     97  3.7   2.46  20.0     1     0     3     1
#> 11  15.5     8 318     150  2.76  3.52  16.9     0     0     3     2
#> 
#> $T_3
#> # A tibble: 10 × 11
#>      mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
#>    <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#>  1  15.2     8 304     150  3.15  3.44  17.3     0     0     3     2
#>  2  13.3     8 350     245  3.73  3.84  15.4     0     0     3     4
#>  3  19.2     8 400     175  3.08  3.84  17.0     0     0     3     2
#>  4  27.3     4  79      66  4.08  1.94  18.9     1     1     4     1
#>  5  26       4 120.     91  4.43  2.14  16.7     0     1     5     2
#>  6  30.4     4  95.1   113  3.77  1.51  16.9     1     1     5     2
#>  7  15.8     8 351     264  4.22  3.17  14.5     0     1     5     4
#>  8  19.7     6 145     175  3.62  2.77  15.5     0     1     5     6
#>  9  15       8 301     335  3.54  3.57  14.6     0     1     5     8
#> 10  21.4     4 121     109  4.11  2.78  18.6     1     1     4     2
#> 
```
