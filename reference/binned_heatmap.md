# Plot Binned Heatmap

Creates a tile-binned frequency heatmap of two variables using
rasterization for efficient handling of large datasets. The function
supports `log10` transformations for axes and fill scale, and allows
customization of axis labels, title, and subtitle. The function can be
useful to visualize the distribution and density of points in a
two-dimensional space, especially for large datasets where traditional
scatter plots may become cluttered. It can help identify patterns,
clusters, and outliers in the data.

## Usage

``` r
binned_heatmap(
  data,
  x,
  y,
  nrow = 100L,
  ncol = 100L,
  log_x = FALSE,
  log_y = FALSE,
  log_fill = FALSE,
  xlab = NULL,
  ylab = NULL,
  title = NULL,
  subtitle = NULL,
  n_breaks = 6L
)
```

## Arguments

- data:

  A data frame containing the variables to plot.

- x, y:

  Character string specifying the column name for the x and y-axis
  variables.

- nrow, ncol:

  Integer specifying the number of rows and columns in the raster grid
  (default: 100).

- log_x, log_y:

  Logical indicating whether to apply log10 transformation to x and y
  axes (default: FALSE).

- log_fill:

  Logical indicating whether to use log10 scale for the fill (default:
  FALSE).

- xlab, ylab:

  Character string for the x and y axis label (default: `NULL`).

- title:

  Character string for the plot title (default: `NULL`).

- subtitle:

  Character string for the plot subtitle (default: `NULL`).

- n_breaks:

  Integer specifying the approximate number of breaks for axes and
  colour bar (default: 6).

## Value

A ggplot2 object representing the heatmap.

## Author

Ahmed El-Gabbas

## Examples

``` r
# ------------------------------------------------
# Bivariate Normal Data (No Skew)
# ------------------------------------------------
n <- 10000
set.seed(1)
df_norm <- data.frame(
  x = rnorm(n, mean = 0, sd = 1),
  y = rnorm(n, mean = 0, sd = 1))
binned_heatmap(df_norm, x = "x", y = "y", title = "Bivariate Normal")


# ------------------------------------------------
# Strongly Right-Skewed (Log-Normal)
# ------------------------------------------------
set.seed(2)
df_lognorm <- data.frame(
  x = rlnorm(n, meanlog = 1, sdlog = 0.6),
  y = rlnorm(n, meanlog = 2, sdlog = 1))
binned_heatmap(
  df_lognorm, x = "x", y = "y",
  title = "Bivariate Log-Normal", log_fill = TRUE)


# ------------------------------------------------
# Left- and Right-Skewed (Beta Shapes)
# ------------------------------------------------
set.seed(3)
df_beta <- data.frame(
  x = rbeta(n, shape1 = 2, shape2 = 7), y = rbeta(n, shape1 = 7, shape2 = 2))
binned_heatmap(df_beta, x = "x", y = "y", title = "Mixed Skewness (Beta)")


# ------------------------------------------------
# Strong Bimodal Data
# ------------------------------------------------
set.seed(4)
x_bimodal <- c(rnorm(n / 2, -2), rnorm(n / 2, 3))
y_bimodal <- c(rnorm(n / 2, 2),  rnorm(n / 2, -3))
df_bimodal <- data.frame(x = x_bimodal, y = y_bimodal)
binned_heatmap(df_bimodal, x = "x", y = "y", title = "Bimodal Distribution")


# ------------------------------------------------
# Clustered Data (Two Clusters, One Skewed)
# ------------------------------------------------
set.seed(5)
n_ct1 <- 6000
n_ct2 <- 4000
df_clusters <- data.frame(
  x = c(rnorm(n_ct1, 2, 0.5), rlnorm(n_ct2, 0.5, 0.8) + 5),
  y = c(rnorm(n_ct1, 2, 0.5), rlnorm(n_ct2, 1, 0.8) + 1))
binned_heatmap(
  df_clusters, x = "x", y = "y",
  title = "Clusters: Gaussian & Skewed",
  subtitle = "Left = normal, Right = lognormal-skewed")


# ------------------------------------------------
# Uniform Data (No Skew or Clustering)
# ------------------------------------------------
set.seed(6)
df_uniform <- data.frame(
  x = runif(n, min = 0, max = 1), y = runif(n, min = 0, max = 1))
binned_heatmap(df_uniform, x = "x", y = "y", title = "Bivariate Uniform")


# ------------------------------------------------
# Example using dismo bioclimatic variables
# ------------------------------------------------

# Plotting frequency heatmaps of bioclimatic variables from the dismo package
ecokit::load_packages(dplyr, dismo, terra)

predictors <- list.files(
  path = paste(system.file(package = "dismo"), "/ex", sep = ""),
  pattern = "grd", full.names = TRUE) %>%
  terra::rast() %>%
  as.data.frame(xy = FALSE) %>%
  tibble::tibble()
head(predictors)
#> # A tibble: 6 × 9
#>    bio1 bio12 bio16 bio17  bio5  bio6  bio7  bio8 biome
#>   <int> <int> <int> <int> <int> <int> <int> <int> <int>
#> 1   113  1800   936    32   242    24   218    73     5
#> 2   112  1556   810    27   265    10   255    66     5
#> 3   112  1263   662    24   302   -14   316    53     5
#> 4   110  1049   532    26   301   -19   319    49     5
#> 5   161   532   276    16   351    19   332    81     8
#> 6   153   855   438    19   340    16   324    76     8

binned_heatmap(
  predictors, x = "bio1", y = "bio17",
  xlab = "Annual Mean Temperature (bio1)",
  ylab = "Precipitation of Driest Quarter (bio17)",
  title = "Heatmap of Bio1 vs Bio17")
#> Error in (function (cond) .Internal(C_tryCatchHelper(addr, 1L, cond)))(structure(list(message = structure("Must group by variables found in `.data`.", names = ""),     trace = structure(list(call = list(pkgdown::build_site_github_pages(new_process = FALSE,         install = FALSE), build_site(pkg, preview = FALSE, install = install,         new_process = new_process, ...), build_site_local(pkg = pkg,         examples = examples, run_dont_run = run_dont_run, seed = seed,         lazy = lazy, override = override, preview = preview,         devel = devel, quiet = quiet), build_reference(pkg, lazy = lazy,         examples = examples, run_dont_run = run_dont_run, seed = seed,         override = override, preview = FALSE, devel = devel),         unwrap_purrr_error(purrr::map(topics, build_reference_topic,             pkg = pkg, lazy = lazy, examples_env = examples_env,             run_dont_run = run_dont_run)), withCallingHandlers(code,             purrr_error_indexed = function(err) {                cnd_signal(err$parent)            }), purrr::map(topics, build_reference_topic, pkg = pkg,             lazy = lazy, examples_env = examples_env, run_dont_run = run_dont_run),         map_("list", .x, .f, ..., .progress = .progress), with_indexed_errors(i = i,             names = names, error_call = .purrr_error_call, call_with_cleanup(map_impl,                 environment(), .type, .progress, n, names, i)),         withCallingHandlers(expr, error = function(cnd) {            if (i == 0L) {            }            else {                message <- c(i = "In index: {i}.")                if (!is.null(names) && !is.na(names[[i]]) &&                   names[[i]] != "") {                  name <- names[[i]]                  message <- c(message, i = "With name: {name}.")                }                else {                  name <- NULL                }                cli::cli_abort(message, location = i, name = name,                   parent = cnd, call = error_call, class = "purrr_error_indexed")            }        }), call_with_cleanup(map_impl, environment(), .type,             .progress, n, names, i), .f(.x[[i]], ...), withCallingHandlers(data_reference_topic(topic,             pkg, examples_env = examples_env, run_dont_run = run_dont_run),             error = function(err) {                cli::cli_abort("Failed to parse Rd in {.file {topic$file_in}}",                   parent = err, call = quote(build_reference()))            }), data_reference_topic(topic, pkg, examples_env = examples_env,             run_dont_run = run_dont_run), run_examples(tags$tag_examples[[1]],             env = if (is.null(examples_env)) NULL else new.env(parent = examples_env),             topic = tools::file_path_sans_ext(topic$file_in),             run_dont_run = run_dont_run), highlight_examples(code,             topic, env = env), downlit::evaluate_and_highlight(code,             fig_save = fig_save_topic, env = eval_env, output_handler = handler),         evaluate::evaluate(code, child_env(env), new_device = TRUE,             output_handler = output_handler), withRestarts(with_handlers({            for (expr in tle$exprs) {                ev <- withVisible(eval(expr, envir))                watcher$capture_plot_and_output()                watcher$print_value(ev$value, ev$visible, envir)            }            TRUE        }, handlers), eval_continue = function() TRUE, eval_stop = function() FALSE),         withRestartList(expr, restarts), withOneRestart(withRestartList(expr,             restarts[-nr]), restarts[[nr]]), doWithOneRestart(return(expr),             restart), withRestartList(expr, restarts[-nr]), withOneRestart(expr,             restarts[[1L]]), doWithOneRestart(return(expr), restart),         with_handlers({            for (expr in tle$exprs) {                ev <- withVisible(eval(expr, envir))                watcher$capture_plot_and_output()                watcher$print_value(ev$value, ev$visible, envir)            }            TRUE        }, handlers), eval(call), eval(call), withCallingHandlers(code,             message = `<fn>`, warning = `<fn>`, error = `<fn>`),         withVisible(eval(expr, envir)), eval(expr, envir), eval(expr,             envir), binned_heatmap(predictors, x = "bio1", y = "bio17",             xlab = "Annual Mean Temperature (bio1)", ylab = "Precipitation of Driest Quarter (bio17)",             title = "Heatmap of Bio1 vs Bio17"), dplyr::mutate(data,             x_bin = (plot_x - min_x)/(max_x - min_x), y_bin = (plot_y -                 min_y)/(max_y - min_y)) %>% dplyr::count(x, y,             plot_x, plot_y, x_bin, y_bin) %>% sf::st_as_sf(coords = c("x_bin",             "y_bin")) %>% terra::vect(), terra::vect(.), sf::st_as_sf(.,             coords = c("x_bin", "y_bin")), dplyr::count(., x,             y, plot_x, plot_y, x_bin, y_bin), count.data.frame(.,             x, y, plot_x, plot_y, x_bin, y_bin), group_by(x,             ..., .add = TRUE, .drop = .drop), group_by.data.frame(x,             ..., .add = TRUE, .drop = .drop), group_by_prepare(.data,             ..., .add = .add, error_call = current_env()), abort(bullets,             call = error_call)), parent = c(0L, 1L, 2L, 3L, 4L,     5L, 4L, 7L, 8L, 9L, 8L, 8L, 12L, 12L, 14L, 15L, 16L, 17L,     18L, 19L, 20L, 21L, 20L, 23L, 24L, 18L, 26L, 27L, 26L, 18L,     18L, 31L, 32L, 33L, 0L, 0L, 0L, 0L, 38L, 38L, 40L, 41L),         visible = c(TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE,         TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE,         TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE,         TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE,         TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE),         namespace = c("pkgdown", "pkgdown", "pkgdown", "pkgdown",         "pkgdown", "base", "purrr", "purrr", "purrr", "base",         "purrr", "pkgdown", "base", "pkgdown", "pkgdown", "pkgdown",         "downlit", "evaluate", "base", "base", "base", "base",         "base", "base", "base", "evaluate", "base", "base", "base",         "base", "base", "base", "ecokit", NA, "terra", "sf",         "dplyr", "dplyr", "dplyr", "dplyr", "dplyr", "rlang"),         scope = c("::", "::", ":::", "::", ":::", "::", "::",         ":::", ":::", "::", ":::", "local", "::", ":::", ":::",         ":::", "::", "::", "::", "local", "local", "local", "local",         "local", "local", ":::", "::", "::", "::", "::", "::",         "::", "::", NA, "::", "::", "::", ":::", "::", ":::",         "::", "::"), error_frame = c(FALSE, FALSE, FALSE, FALSE,         FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE,         FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE,         FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE,         FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE,         FALSE, TRUE, FALSE, FALSE, FALSE, FALSE)), row.names = c(NA,     -42L), version = 2L, class = c("rlang_trace", "rlib_trace",     "tbl", "data.frame")), parent = NULL, body = c(x1 = "Column `x` is not found.",     x2 = "Column `y` is not found."), rlang = list(inherit = TRUE),     call = dplyr::count(., x, y, plot_x, plot_y, x_bin, y_bin),     use_cli_format = TRUE), class = c("rlang_error", "error", "condition"))): error in evaluating the argument 'x' in selecting a method for function 'vect': Must group by variables found in `.data`.
#> Column `x` is not found.
#> Column `y` is not found.

binned_heatmap(
  predictors, x = "bio12", y = "bio8",
  xlab = "Annual Precipitation (bio12)",
  ylab = "Mean Temperature of Wettest Quarter (bio8)",
  title = "Heatmap of Bio12 vs Bio8")
#> Error in (function (cond) .Internal(C_tryCatchHelper(addr, 1L, cond)))(structure(list(message = structure("Must group by variables found in `.data`.", names = ""),     trace = structure(list(call = list(pkgdown::build_site_github_pages(new_process = FALSE,         install = FALSE), build_site(pkg, preview = FALSE, install = install,         new_process = new_process, ...), build_site_local(pkg = pkg,         examples = examples, run_dont_run = run_dont_run, seed = seed,         lazy = lazy, override = override, preview = preview,         devel = devel, quiet = quiet), build_reference(pkg, lazy = lazy,         examples = examples, run_dont_run = run_dont_run, seed = seed,         override = override, preview = FALSE, devel = devel),         unwrap_purrr_error(purrr::map(topics, build_reference_topic,             pkg = pkg, lazy = lazy, examples_env = examples_env,             run_dont_run = run_dont_run)), withCallingHandlers(code,             purrr_error_indexed = function(err) {                cnd_signal(err$parent)            }), purrr::map(topics, build_reference_topic, pkg = pkg,             lazy = lazy, examples_env = examples_env, run_dont_run = run_dont_run),         map_("list", .x, .f, ..., .progress = .progress), with_indexed_errors(i = i,             names = names, error_call = .purrr_error_call, call_with_cleanup(map_impl,                 environment(), .type, .progress, n, names, i)),         withCallingHandlers(expr, error = function(cnd) {            if (i == 0L) {            }            else {                message <- c(i = "In index: {i}.")                if (!is.null(names) && !is.na(names[[i]]) &&                   names[[i]] != "") {                  name <- names[[i]]                  message <- c(message, i = "With name: {name}.")                }                else {                  name <- NULL                }                cli::cli_abort(message, location = i, name = name,                   parent = cnd, call = error_call, class = "purrr_error_indexed")            }        }), call_with_cleanup(map_impl, environment(), .type,             .progress, n, names, i), .f(.x[[i]], ...), withCallingHandlers(data_reference_topic(topic,             pkg, examples_env = examples_env, run_dont_run = run_dont_run),             error = function(err) {                cli::cli_abort("Failed to parse Rd in {.file {topic$file_in}}",                   parent = err, call = quote(build_reference()))            }), data_reference_topic(topic, pkg, examples_env = examples_env,             run_dont_run = run_dont_run), run_examples(tags$tag_examples[[1]],             env = if (is.null(examples_env)) NULL else new.env(parent = examples_env),             topic = tools::file_path_sans_ext(topic$file_in),             run_dont_run = run_dont_run), highlight_examples(code,             topic, env = env), downlit::evaluate_and_highlight(code,             fig_save = fig_save_topic, env = eval_env, output_handler = handler),         evaluate::evaluate(code, child_env(env), new_device = TRUE,             output_handler = output_handler), withRestarts(with_handlers({            for (expr in tle$exprs) {                ev <- withVisible(eval(expr, envir))                watcher$capture_plot_and_output()                watcher$print_value(ev$value, ev$visible, envir)            }            TRUE        }, handlers), eval_continue = function() TRUE, eval_stop = function() FALSE),         withRestartList(expr, restarts), withOneRestart(withRestartList(expr,             restarts[-nr]), restarts[[nr]]), doWithOneRestart(return(expr),             restart), withRestartList(expr, restarts[-nr]), withOneRestart(expr,             restarts[[1L]]), doWithOneRestart(return(expr), restart),         with_handlers({            for (expr in tle$exprs) {                ev <- withVisible(eval(expr, envir))                watcher$capture_plot_and_output()                watcher$print_value(ev$value, ev$visible, envir)            }            TRUE        }, handlers), eval(call), eval(call), withCallingHandlers(code,             message = `<fn>`, warning = `<fn>`, error = `<fn>`),         withVisible(eval(expr, envir)), eval(expr, envir), eval(expr,             envir), binned_heatmap(predictors, x = "bio12", y = "bio8",             xlab = "Annual Precipitation (bio12)", ylab = "Mean Temperature of Wettest Quarter (bio8)",             title = "Heatmap of Bio12 vs Bio8"), dplyr::mutate(data,             x_bin = (plot_x - min_x)/(max_x - min_x), y_bin = (plot_y -                 min_y)/(max_y - min_y)) %>% dplyr::count(x, y,             plot_x, plot_y, x_bin, y_bin) %>% sf::st_as_sf(coords = c("x_bin",             "y_bin")) %>% terra::vect(), terra::vect(.), sf::st_as_sf(.,             coords = c("x_bin", "y_bin")), dplyr::count(., x,             y, plot_x, plot_y, x_bin, y_bin), count.data.frame(.,             x, y, plot_x, plot_y, x_bin, y_bin), group_by(x,             ..., .add = TRUE, .drop = .drop), group_by.data.frame(x,             ..., .add = TRUE, .drop = .drop), group_by_prepare(.data,             ..., .add = .add, error_call = current_env()), abort(bullets,             call = error_call)), parent = c(0L, 1L, 2L, 3L, 4L,     5L, 4L, 7L, 8L, 9L, 8L, 8L, 12L, 12L, 14L, 15L, 16L, 17L,     18L, 19L, 20L, 21L, 20L, 23L, 24L, 18L, 26L, 27L, 26L, 18L,     18L, 31L, 32L, 33L, 0L, 0L, 0L, 0L, 38L, 38L, 40L, 41L),         visible = c(TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE,         TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE,         TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE,         TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE,         TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE),         namespace = c("pkgdown", "pkgdown", "pkgdown", "pkgdown",         "pkgdown", "base", "purrr", "purrr", "purrr", "base",         "purrr", "pkgdown", "base", "pkgdown", "pkgdown", "pkgdown",         "downlit", "evaluate", "base", "base", "base", "base",         "base", "base", "base", "evaluate", "base", "base", "base",         "base", "base", "base", "ecokit", NA, "terra", "sf",         "dplyr", "dplyr", "dplyr", "dplyr", "dplyr", "rlang"),         scope = c("::", "::", ":::", "::", ":::", "::", "::",         ":::", ":::", "::", ":::", "local", "::", ":::", ":::",         ":::", "::", "::", "::", "local", "local", "local", "local",         "local", "local", ":::", "::", "::", "::", "::", "::",         "::", "::", NA, "::", "::", "::", ":::", "::", ":::",         "::", "::"), error_frame = c(FALSE, FALSE, FALSE, FALSE,         FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE,         FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE,         FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE,         FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE,         FALSE, TRUE, FALSE, FALSE, FALSE, FALSE)), row.names = c(NA,     -42L), version = 2L, class = c("rlang_trace", "rlib_trace",     "tbl", "data.frame")), parent = NULL, body = c(x1 = "Column `x` is not found.",     x2 = "Column `y` is not found."), rlang = list(inherit = TRUE),     call = dplyr::count(., x, y, plot_x, plot_y, x_bin, y_bin),     use_cli_format = TRUE), class = c("rlang_error", "error", "condition"))): error in evaluating the argument 'x' in selecting a method for function 'vect': Must group by variables found in `.data`.
#> Column `x` is not found.
#> Column `y` is not found.
```
