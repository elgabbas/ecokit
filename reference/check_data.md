# Check Integrity of Data Files

Validates a data file by checking its extension and attempting to load
its contents. A file is considered valid if it exists, is non-empty, has
a supported extension, and loads successfully with a non-null object.
Supports `RData`, `qs2`, `rds`, and `feather` file types.

## Usage

``` r
check_data(
  file = NULL,
  warning = TRUE,
  all_okay = TRUE,
  n_threads = 1L,
  timeout = 120L
)

check_rdata(file, warning = TRUE, timeout = 120L)

check_qs(file, warning = TRUE, n_threads = 1L, timeout = 120L)

check_rds(file, warning = TRUE, timeout = 120L)

check_feather(file, warning = TRUE, timeout = 120L)
```

## Arguments

- file:

  Character vector. Path to a data file (e.g., `.rdata`, `.qs2`, `.rds`,
  `.feather`).

- warning:

  Logical. If `TRUE` (default), warnings are issued for invalid files
  (e.g., non-existent, wrong extension, or loading failure).

- all_okay:

  Logical. If `TRUE` (default), returns a single logical output
  indicating the integrity of all files; if `FALSE`, returns logical
  vectors for each file.

- n_threads:

  Integer. Number of threads for reading `qs2` files. Must be a positive
  integer. See [qs2::qs_read](https://rdrr.io/pkg/qs2/man/qs_read.html)
  for more details. If it exceeds
  [`parallelly::availableCores()`](https://parallelly.futureverse.org/reference/availableCores.html),
  it is silently clamped to the number of available cores (with a
  warning); see
  [`validate_n_cores()`](https://elgabbas.github.io/ecokit/reference/validators.md).

- timeout:

  Integer. Maximum time in seconds allowed for the file-loading attempt
  (per file) before it is treated as a failure. Default `120L`.

## Value

Logical: `TRUE` if all checks pass; `FALSE` otherwise.

## Details

The `check_data()` function determines the file type based on its
extension (case-insensitive). If the extension is unrecognised, it
returns `FALSE`. Supported file types:

- **RData**: Checked with `check_rdata()`, read using
  [load_as](https://elgabbas.github.io/ecokit/reference/load_as.md)

- **qs2**: Checked with `check_qs()`, read using
  [qs2::qs_read](https://rdrr.io/pkg/qs2/man/qs_read.html)

- **rds**: Checked with `check_rds()`, read using
  [readRDS](https://rdrr.io/r/base/readRDS.html)

- **feather**: Checked with `check_feather()`, read using
  [arrow::read_feather](https://arrow.apache.org/docs/r/reference/read_feather.html)

  For all file types, the actual loading attempt is performed in a
  disposable background R process via
  [callr::r](https://callr.r-lib.org/reference/r.html). This is
  important because reading a corrupted `feather`/Arrow IPC file (and,
  less commonly, a corrupted `qs2` or `RData` file) with the native
  readers can crash the R process with a segmentation fault rather than
  throwing a catchable error. Such a crash cannot be intercepted with
  [`try()`](https://rdrr.io/r/base/try.html)/[`tryCatch()`](https://rdrr.io/r/base/conditions.html)
  and would terminate the calling session — or, under parallel
  processing (e.g. `future`/`furrr`), silently kill a worker. Running
  the load in a subprocess confines any crash to that subprocess;
  [callr::r](https://callr.r-lib.org/reference/r.html) converts it into
  a normal, catchable R error in the calling process, which
  `check_data()` reports as `FALSE` (with an optional warning).

  For `feather` files specifically, a lightweight, pure-R check of the
  Arrow IPC file-format magic bytes (`"ARROW1"` at the start and end of
  the file) is performed first. This is fast, allocates no native
  memory, and filters out most corrupted files before
  [`arrow::read_feather`](https://arrow.apache.org/docs/r/reference/read_feather.html)
  is ever called.

## Author

Ahmed El-Gabbas

## Examples

``` r
require(ecokit)
ecokit::load_packages(fs, arrow)

# Setup temporary directory
temp_dir <- fs::path_temp("load_multiple")
fs::dir_create(temp_dir)

# |||||||||||||||||||||||||||||||||||||||
# Validate RData files
# |||||||||||||||||||||||||||||||||||||||

# valid RData file
data <- data.frame(x = 1:5)
rdata_file <- fs::path(temp_dir, "valid.Rdata")
save(data, file = rdata_file)
check_rdata(rdata_file)
#> [1] TRUE

# Invalid RData file (corrupted)
bad_rdata <- fs::path(temp_dir, "invalid.Rdata")
writeLines("not an RData file", bad_rdata)
check_rdata(bad_rdata)
#> Warning: Failed to load RData file: /tmp/RtmpKKokny/load_multiple/invalid.Rdata
#> [1] FALSE
check_rdata(bad_rdata, warning = FALSE)
#> [1] FALSE

# |||||||||||||||||||||||||||||||||||||||
# Validate qs2 files
# |||||||||||||||||||||||||||||||||||||||

# Valid qs2 file
qs_file <- fs::path(temp_dir, "valid.qs2")
qs2::qs_save(data, qs_file, nthreads = 1)
check_qs(qs_file, n_threads = 1L)
#> [1] TRUE

# Invalid qs2 file (corrupted)
bad_qs <- fs::path(temp_dir, "invalid.qs2")
writeLines("not a qs2 file", bad_qs)
check_qs(bad_qs, n_threads = 1L)
#> Warning: Failed to load qs2 file: /tmp/RtmpKKokny/load_multiple/invalid.qs2
#> [1] FALSE
check_qs(bad_qs, n_threads = 1L, warning = FALSE)
#> [1] FALSE

# |||||||||||||||||||||||||||||||||||||||
# Validate rds files
# |||||||||||||||||||||||||||||||||||||||

# Valid rds file
rds_file <- fs::path(temp_dir, "valid.rds")
saveRDS(data, rds_file)
check_rds(rds_file)
#> [1] TRUE

# Invalid rds file (corrupted)
bad_rds <- fs::path(temp_dir, "invalid.rds")
writeLines("not an rds file", bad_rds)
check_rds(bad_rds)
#> Warning: Failed to load rds file: /tmp/RtmpKKokny/load_multiple/invalid.rds
#> [1] FALSE
check_rds(bad_rds, warning = FALSE)
#> [1] FALSE

# |||||||||||||||||||||||||||||||||||||||
# Validate feather files
# |||||||||||||||||||||||||||||||||||||||

# Valid feather file
feather_file <- fs::path(temp_dir, "valid.feather")
arrow::write_feather(data, feather_file)
check_feather(feather_file)
#> [1] TRUE

# Invalid feather file (corrupted)
bad_feather <- fs::path(temp_dir, "invalid.feather")
writeLines("not a feather file", bad_feather)
check_feather(bad_feather)
#> Warning: Failed to load feather file: /tmp/RtmpKKokny/load_multiple/invalid.feather
#> [1] FALSE
check_feather(bad_feather, warning = FALSE)
#> [1] FALSE

# |||||||||||||||||||||||||||||||||||||||
# Non-existent file
# |||||||||||||||||||||||||||||||||||||||

check_data("nonexistent.rds")
#> Warning: File does not exist: `/home/runner/work/ecokit/ecokit/docs/reference/nonexistent.rds`
#> [1] FALSE

# |||||||||||||||||||||||||||||||||||||||
# check_data
# |||||||||||||||||||||||||||||||||||||||

all_files <- c(
  rdata_file, bad_rdata, qs_file, bad_qs, rds_file, bad_rds,
  feather_file, bad_feather)

check_data(all_files)
#> Warning: Failed to load RData file: /tmp/RtmpKKokny/load_multiple/invalid.Rdata
#> Warning: Failed to load qs2 file: /tmp/RtmpKKokny/load_multiple/invalid.qs2
#> Warning: Failed to load rds file: /tmp/RtmpKKokny/load_multiple/invalid.rds
#> Warning: Failed to load feather file: /tmp/RtmpKKokny/load_multiple/invalid.feather
#> [1] FALSE

check_data(all_files, warning = FALSE)
#> [1] FALSE

check_data(all_files, all_okay = FALSE)
#> Warning: Failed to load RData file: /tmp/RtmpKKokny/load_multiple/invalid.Rdata
#> Warning: Failed to load qs2 file: /tmp/RtmpKKokny/load_multiple/invalid.qs2
#> Warning: Failed to load rds file: /tmp/RtmpKKokny/load_multiple/invalid.rds
#> Warning: Failed to load feather file: /tmp/RtmpKKokny/load_multiple/invalid.feather
#> [1]  TRUE FALSE  TRUE FALSE  TRUE FALSE  TRUE FALSE

check_data(all_files, all_okay = FALSE, warning = FALSE)
#> [1]  TRUE FALSE  TRUE FALSE  TRUE FALSE  TRUE FALSE

# clean up
fs::file_delete(all_files)
fs::dir_delete(temp_dir)
```
