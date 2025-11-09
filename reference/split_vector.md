# Split a vector into smaller chunks

This function divides a given vector into a specified number of smaller
chunks. It is useful for partitioning data into more manageable pieces
or for parallel processing tasks.

## Usage

``` r
split_vector(vector = NULL, n_splits = NULL, prefix = "Chunk")
```

## Arguments

- vector:

  A numeric or character vector that you want to split.

- n_splits:

  Integer. Number of chunks to split the vector into. It must not exceed
  the length of the vector.

- prefix:

  Character. prefix for the names of the chunks in the returned list.
  Defaults to `"Chunk"`.

## Value

A list of vectors, where each vector represents a chunk of the original
vector. The names of the list elements are generated using the specified
prefix followed by an underscore and the chunk number.

## Author

Ahmed El-Gabbas

## Examples

``` r
split_vector(vector = seq_len(100), n_splits = 3)
#> $Chunk_1
#>  [1]  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25
#> [26] 26 27 28 29 30 31 32 33 34
#> 
#> $Chunk_2
#>  [1] 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59
#> [26] 60 61 62 63 64 65 66 67
#> 
#> $Chunk_3
#>  [1]  68  69  70  71  72  73  74  75  76  77  78  79  80  81  82  83  84  85  86
#> [20]  87  88  89  90  91  92  93  94  95  96  97  98  99 100
#> 

# -------------------------------------------

split_vector(vector = seq_len(100), n_splits = 2, prefix = "T")
#> $T_1
#>  [1]  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25
#> [26] 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50
#> 
#> $T_2
#>  [1]  51  52  53  54  55  56  57  58  59  60  61  62  63  64  65  66  67  68  69
#> [20]  70  71  72  73  74  75  76  77  78  79  80  81  82  83  84  85  86  87  88
#> [39]  89  90  91  92  93  94  95  96  97  98  99 100
#> 
```
