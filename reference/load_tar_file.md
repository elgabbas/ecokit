# Load a File from a Tar Archive

Extracts a single file from a tar archive into a temporary directory,
loads it, and returns the in-memory object. The temporary directory is
always deleted on exit, so file-backed objects such as `SpatRaster` are
read fully into memory before the directory is removed.

## Usage

``` r
load_tar_file(
  tar_file,
  file_to_extract,
  load_fun = "ecokit::load_as",
  wrap_r = TRUE,
  ...
)
```

## Arguments

- tar_file:

  Character. Path to the tar archive file. Supported extensions: `.tar`,
  `.tar.gz`, `.tgz`, `.tar.bz2`, `.tbz2`.

- file_to_extract:

  Character. Path of the file to extract from the archive, exactly as it
  appears in the archive listing (may include subdirectory components).

- load_fun:

  Either a function or a character string naming a function (optionally
  namespace-qualified, e.g. `"readr::read_csv"`) used to load the
  extracted file for non-TIFF,
  non-[`ecokit::load_as`](https://elgabbas.github.io/ecokit/reference/load_as.md)-handled
  types. Defaults to
  [load_as](https://elgabbas.github.io/ecokit/reference/load_as.md).
  Ignored for TIFF files and for files whose extension is handled
  natively by
  [`load_as()`](https://elgabbas.github.io/ecokit/reference/load_as.md).

- wrap_r:

  Logical. Only relevant when the extracted file is a TIFF. If `TRUE`
  (default), the in-memory `SpatRaster` is wrapped with
  [`terra::wrap()`](https://rspatial.github.io/terra/reference/wrap.html)
  before being returned, making it safe for serialisation (e.g. passing
  across parallel workers). Set to `FALSE` to return a plain
  `SpatRaster`.

- ...:

  Additional arguments passed to `load_fun` (ignored for TIFF files).

## Value

For TIFF files: a `PackedSpatRaster` (when `wrap_r = TRUE`) or a
`SpatRaster` fully loaded into memory (when `wrap_r = FALSE`). For all
other types: the object returned by `load_fun` or
[`load_as()`](https://elgabbas.github.io/ecokit/reference/load_as.md),
as appropriate.

## Details

For TIFF files (extensions `.tif` or `.tiff`), the function always uses
[`terra::rast()`](https://rspatial.github.io/terra/reference/rast.html)
followed by
[`terra::toMemory()`](https://rspatial.github.io/terra/reference/toMemory.html)
to ensure the raster is fully in memory before the temporary extraction
directory is deleted. The `load_fun` argument is therefore **ignored**
for TIFF files. If `wrap_r = TRUE` (the default), the in-memory
`SpatRaster` is additionally wrapped with
[`terra::wrap()`](https://rspatial.github.io/terra/reference/wrap.html)
to make it serialisable for parallel or inter-process transfer.

For files with extensions recognised by
[`load_as()`](https://elgabbas.github.io/ecokit/reference/load_as.md)
(`.rdata`, `.qs2`, `.rds`, `.feather`), that function is called directly
and `load_fun` is ignored.

For all other file types, the function calls `load_fun` on the extracted
file path.

## Author

Ahmed El-Gabbas

## Examples

``` r
ecokit::load_packages(terra, stringr, fs, magrittr)

# Build an example tar file containing 3 files
tif_file <- system.file("ex/elev.tif", package = "terra")
rds_file <- fs::file_temp(ext = ".rds")
ecokit::save_as(mtcars, out_path = rds_file)
csv_file <- tempfile(fileext = ".csv")
write.csv(iris, csv_file, row.names = FALSE)
tmp_tar <- fs::file_temp(ext = ".tar")
file_list <- c(tif_file, csv_file, rds_file)
base_names <- basename(file_list)
dirs <- dirname(file_list)
for (i in seq_along(file_list)) {
  tar_flag <- ifelse(i == 1L, "c", "r")
  tar_args <- stringr::str_glue(
    "tar -{tar_flag}f {shQuote(tmp_tar)} -C {shQuote(dirs[i])} \\
    {shQuote(base_names[i])}")
  invisible(system(tar_args))
}

# List contents of the tar file
print(system2("tar", c("-tf", tmp_tar), stdout = TRUE))
#> [1] "elev.tif"             "file22529d0915d.csv"  "file225261ab92d6.rds"

# TIFF: returned fully in memory (wrapped by default)
r <- load_tar_file(tar_file = tmp_tar, file_to_extract = "elev.tif")

# TIFF: unwrapped SpatRaster
r2 <- load_tar_file(
  tar_file = tmp_tar, file_to_extract = "elev.tif", wrap_r = FALSE)
terra::sources(r2)  # should be "" (in memory)
#> [1] ""

# CSV via base read.csv
load_tar_file(
  tar_file = tmp_tar, file_to_extract = basename(csv_file),
  load_fun = "readr::read_csv", col_types = "c") %>%
  head()
#> Error in (function (cond) .Internal(C_tryCatchHelper(addr, 1L, cond)))(structure(list(message = "\033[1m\033[31mThe following required packages are missing: readr. Please install them to proceed.\033[39m\033[22m",     trace = structure(list(call = list(pkgdown::build_site_github_pages(new_process = FALSE,         install = FALSE, lazy = TRUE), build_site(pkg, preview = FALSE,         install = install, new_process = new_process, ...), build_site_local(pkg = pkg,         examples = examples, run_dont_run = run_dont_run, seed = seed,         lazy = lazy, override = override, preview = preview,         devel = devel, quiet = quiet), build_reference(pkg, lazy = lazy,         examples = examples, run_dont_run = run_dont_run, seed = seed,         override = override, preview = FALSE, devel = devel),         unwrap_purrr_error(purrr::map(topics, build_reference_topic,             pkg = pkg, lazy = lazy, examples_env = examples_env,             run_dont_run = run_dont_run)), withCallingHandlers(code,             purrr_error_indexed = function(err) {                cnd_signal(err$parent)            }), purrr::map(topics, build_reference_topic, pkg = pkg,             lazy = lazy, examples_env = examples_env, run_dont_run = run_dont_run),         map_("list", .x, .f, ..., .progress = .progress), with_indexed_errors(i = i,             names = names, error_call = .purrr_error_call, call_with_cleanup(map_impl,                 environment(), .type, .progress, n, names, i)),         withCallingHandlers(expr, error = function(cnd) {            if (i == 0L) {            }            else {                message <- c(i = "In index: {i}.")                if (!is.null(names) && !is.na(names[[i]]) &&                   names[[i]] != "") {                  name <- names[[i]]                  message <- c(message, i = "With name: {name}.")                }                else {                  name <- NULL                }                cli::cli_abort(message, location = i, name = name,                   parent = cnd, call = error_call, class = "purrr_error_indexed")            }        }), call_with_cleanup(map_impl, environment(), .type,             .progress, n, names, i), .f(.x[[i]], ...), withCallingHandlers(data_reference_topic(topic,             pkg, examples_env = examples_env, run_dont_run = run_dont_run),             error = function(err) {                cli::cli_abort("Failed to parse Rd in {.file {topic$file_in}}",                   parent = err, call = quote(build_reference()))            }), data_reference_topic(topic, pkg, examples_env = examples_env,             run_dont_run = run_dont_run), run_examples(tags$tag_examples[[1]],             env = if (is.null(examples_env)) NULL else new.env(parent = examples_env),             topic = tools::file_path_sans_ext(topic$file_in),             run_dont_run = run_dont_run), highlight_examples(code,             topic, env = env), downlit::evaluate_and_highlight(code,             fig_save = fig_save_topic, env = eval_env, output_handler = handler),         evaluate::evaluate(code, child_env(env), new_device = TRUE,             output_handler = output_handler), withRestarts(with_handlers({            for (expr in tle$exprs) {                ev <- withVisible(eval(expr, envir))                watcher$capture_plot_and_output()                watcher$print_value(ev$value, ev$visible, envir)            }            TRUE        }, handlers), eval_continue = function() TRUE, eval_stop = function() FALSE),         withRestartList(expr, restarts), withOneRestart(withRestartList(expr,             restarts[-nr]), restarts[[nr]]), doWithOneRestart(return(expr),             restart), withRestartList(expr, restarts[-nr]), withOneRestart(expr,             restarts[[1L]]), doWithOneRestart(return(expr), restart),         with_handlers({            for (expr in tle$exprs) {                ev <- withVisible(eval(expr, envir))                watcher$capture_plot_and_output()                watcher$print_value(ev$value, ev$visible, envir)            }            TRUE        }, handlers), eval(call), eval(call), withCallingHandlers(code,             message = `<fn>`, warning = `<fn>`, error = `<fn>`),         withVisible(eval(expr, envir)), eval(expr, envir), eval(expr,             envir), load_tar_file(tar_file = tmp_tar, file_to_extract = basename(csv_file),             load_fun = "readr::read_csv", col_types = "c") %>%             head(), head(.), load_tar_file(tar_file = tmp_tar,             file_to_extract = basename(csv_file), load_fun = "readr::read_csv",             col_types = "c"), ecokit::check_packages(pkg_fun[1L]),         ecokit::stop_ctx(paste0("The following required packages are missing: ",             toString(packages[!packages_available]), ". Please install them to proceed."),             ...), rlang::abort(message = full_msg, ..., class = class,             call = call, parent = parent)), parent = c(0L, 1L,     2L, 3L, 4L, 5L, 4L, 7L, 8L, 9L, 8L, 8L, 12L, 12L, 14L, 15L,     16L, 17L, 18L, 19L, 20L, 21L, 20L, 23L, 24L, 18L, 26L, 27L,     26L, 18L, 18L, 31L, 32L, 0L, 32L, 35L, 36L, 37L), visible = c(TRUE,     TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE,     TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE,     TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE,     TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, FALSE), namespace = c("pkgdown",     "pkgdown", "pkgdown", "pkgdown", "pkgdown", "base", "purrr",     "purrr", "purrr", "base", "purrr", "pkgdown", "base", "pkgdown",     "pkgdown", "pkgdown", "downlit", "evaluate", "base", "base",     "base", "base", "base", "base", "base", "evaluate", "base",     "base", "base", "base", "base", "base", NA, "utils", "ecokit",     "ecokit", "ecokit", "rlang"), scope = c("::", "::", ":::",     "::", ":::", "::", "::", ":::", ":::", "::", ":::", "local",     "::", ":::", ":::", ":::", "::", "::", "::", "local", "local",     "local", "local", "local", "local", ":::", "::", "::", "::",     "::", "::", "::", NA, "::", "::", "::", "::", "::")), row.names = c(NA,     -38L), version = 2L, class = c("rlang_trace", "rlib_trace",     "tbl", "data.frame")), parent = NULL, rlang = list(inherit = TRUE),     call = ecokit::check_packages(pkg_fun[1L])), class = c("rlang_error", "error", "condition"))): error in evaluating the argument 'x' in selecting a method for function 'head': The following required packages are missing: readr. Please install them to proceed.

# RDS (handled automatically by ecokit::load_as)
load_tar_file(tar_file = tmp_tar, file_to_extract = basename(rds_file)) %>%
  head()
#>                    mpg cyl disp  hp drat    wt  qsec vs am gear carb
#> Mazda RX4         21.0   6  160 110 3.90 2.620 16.46  0  1    4    4
#> Mazda RX4 Wag     21.0   6  160 110 3.90 2.875 17.02  0  1    4    4
#> Datsun 710        22.8   4  108  93 3.85 2.320 18.61  1  1    4    1
#> Hornet 4 Drive    21.4   6  258 110 3.08 3.215 19.44  1  0    3    1
#> Hornet Sportabout 18.7   8  360 175 3.15 3.440 17.02  0  0    3    2
#> Valiant           18.1   6  225 105 2.76 3.460 20.22  1  0    3    1

if (FALSE) { # \dontrun{
# Invalid load_fun: errors with a clear message
load_tar_file(
  tar_file = tmp_tar, file_to_extract = basename(csv_file),
  load_fun = "function_name")
} # }

# clean up
fs::file_delete(tmp_tar)
```
