#' Argument validation helpers for ecokit
#'
#' A family of small, fast-failing validators used throughout `ecokit` (and
#' packages depending on it) to enforce argument types and formats —
#' particularly for HPC/SLURM job configuration (`mod_slurm()`) and parallel
#' processing setup (`set_parallel()`).
#'
#' @param x Input value
#' - For `is_integer()` and `validate_n_cores()`, a numeric value to check.
#' - For `validate_strategy()`, a character string naming a `future` strategy.
#' - For `validate_slurm_runtime()` and `validate_slurm_ram()`, a character
#'   string with a SLURM time or memory specification.
#' @param warning Logical, used only by `validate_slurm_runtime()`. If `TRUE`
#' (default), an invalid runtime string raises an error via
#' [ecokit::stop_ctx]. If `FALSE`, an invalid runtime string instead raises a
#' [base::warning] and the function returns `FALSE`.
#' @return
#' - `is_integer()`: a single logical (`TRUE`/`FALSE`) for numeric input;
#' errors if `x` is `NULL`.
#' - `validate_n_cores()`: a single integer, clamped to
#' [parallelly::availableCores()] if `x` exceeds it (with a warning).
#' - `validate_strategy()`, `validate_slurm_ram()`: the unchanged input `x` if
#' valid; otherwise an error.
#' - `validate_slurm_runtime()`: the unchanged input `x` if valid; otherwise an
#' error (`warning = TRUE`, default) or `FALSE` with a warning
#' (`warning = FALSE`).
#' @details
#' - `is_integer()`: checks whether `x` is a single positive whole-number
#' value (e.g. `5`, `5L`, `5.0`). Returns `FALSE` for non-scalars, `NA`, zero,
#' negative, non-integer, or non-numeric values (without erroring), but throws
#' an error if `x` is `NULL`.
#' - `validate_n_cores()`: validates a requested core count `x`. Must be a
#' positive integer scalar (checked via `is_integer()`; otherwise errors). If
#' `x` exceeds [parallelly::availableCores()], a warning is issued and the
#' number of available cores is used instead.
#' - `validate_strategy()`: validates a `future` parallelisation strategy
#' name `x`. Must be one of `"sequential"`, `"multisession"`, `"multicore"`, or
#' `"cluster"`.
#' - `validate_slurm_runtime()`: validates a SLURM `--time` string `x`.
#' Accepted formats follow SLURM conventions: `"minutes"`, `"minutes:seconds"`,
#' `"hours:minutes:seconds"`, `"days-hours"`, `"days-hours:minutes"`, or
#' `"days-hours:minutes:seconds"`, with hours `00`-`23` and minutes/seconds
#' `00`-`59`.
#' - `validate_slurm_ram()`: validates a SLURM `--mem` string `x`. Must be a
#' positive integer immediately followed by an uppercase unit: `K`, `M`, `G`,
#' `T`, or their long forms `KB`, `MB`, `GB`, `TB`.
#'
#' @author Ahmed El-Gabbas
#' @name validators
#' @examples
#' # is_integer
#' is_integer(5)
#' is_integer(5L)
#' is_integer(5.5)
#' is_integer(-1)
#' is_integer(NA)
#' is_integer(c(1, 2))
#' is_integer("5")
#'
#' \dontrun{
#'   is_integer(NULL) # Errors: `x` cannot be NULL
#' }
#'
#'
#' # validate_n_cores
#' validate_n_cores(2)
#'
#' # Warns and is clamped to the number of available cores
#' validate_n_cores(1000L)
#'
#' \dontrun{
#'   # Errors: not a positive integer scalar
#'   validate_n_cores(-1)
#'   validate_n_cores("2")
#' }
#'
#'
#' # validate_strategy
#' validate_strategy("multisession")
#' \dontrun{
#'   validate_strategy("parallel") # Errors: not a valid `future` strategy
#' }
#'
#' # validate_slurm_runtime ----
#' validate_slurm_runtime("30")
#' validate_slurm_runtime("2:00:00")
#' validate_slurm_runtime("0-12:00:00")
#' validate_slurm_runtime("5-23:59")
#' validate_slurm_runtime("2:00")
#'
#' \dontrun{
#'   validate_slurm_runtime("2:70:00")     # Errors: invalid minutes
#'   validate_slurm_runtime("12-24:00:00") # Errors: invalid hours
#'   validate_slurm_runtime("abc")         # Errors: not a SLURM time format
#' }
#'
#' # Returns FALSE with a warning instead of erroring
#' validate_slurm_runtime("abc", warning = FALSE)
#'
#'
#' # validate_slurm_ram ----
#' validate_slurm_ram("8G")
#' validate_slurm_ram("1024M")
#' validate_slurm_ram("32GB")
#' validate_slurm_ram("1T")
#'
#' \dontrun{
#'   validate_slurm_ram("500")    # Errors: missing unit
#'   validate_slurm_ram("500m")   # Errors: lowercase unit not accepted
#'   validate_slurm_ram("4.5G")   # Errors: non-integer amount
#'   validate_slurm_ram("100MBs") # Errors: trailing characters
#'   validate_slurm_ram("GB32")   # Errors: unit before amount
#' }
NULL

## |------------------------------------------------------------------------| #
# is_integer ----
## |------------------------------------------------------------------------| #

#' @rdname validators
#' @order 1
#' @export

is_integer <- function(x) {

  if (is.null(x)) {
    ecokit::stop_ctx("`x` must be a numeric value, not NULL.")
  }

  if (length(x) != 1L || is.na(x) || !is.numeric(x)) {
    return(FALSE)
  }

  if (x < 1L || x != as.integer(x)) {
    return(FALSE)
  }

  TRUE
}

## |------------------------------------------------------------------------| #
# validate_n_cores ----
## |------------------------------------------------------------------------| #

#' @rdname validators
#' @order 2
#' @export

validate_n_cores <- function(x) {

  ecokit::check_args(args_to_check = "x", args_type = "numeric")

  if (isFALSE(is_integer(x))) {
    ecokit::stop_ctx(
      "`x` must be a positive integer of length 1",
      x = x, class_x = class(x), length_x = length(x))
  }

  max_cores <- parallelly::availableCores()

  if (x > max_cores) {
    warning(
      stringr::str_glue(
        "`x` ({x}) exceeds available cores. Using all available",
        " cores ({max_cores})"),
      call. = FALSE)
    x <- max_cores
  }

  as.integer(x)
}

## |------------------------------------------------------------------------| #
# validate_strategy ----
## |------------------------------------------------------------------------| #

#' @rdname validators
#' @order 3
#' @export

validate_strategy <- function(x) {

  ecokit::check_args(args_to_check = "x", args_type = "character")

  if (length(x) != 1L || is.na(x) || !nzchar(x)) {
    ecokit::stop_ctx(
      "`x` must be a non-empty character string of length 1",
      x = x, class_x = class(x), length_x = length(x))
  }

  valid_strategies <- c("sequential", "multisession", "multicore", "cluster")

  if (!x %in% valid_strategies) {
    ecokit::stop_ctx(
      "`x` must be one of the valid `future` strategies",
      x = x, valid_strategies = valid_strategies)
  }

  x
}

## |------------------------------------------------------------------------| #
# validate_slurm_runtime ----
## |------------------------------------------------------------------------| #

#' @rdname validators
#' @order 4
#' @export

validate_slurm_runtime <- function(x, warning = TRUE) {

  ecokit::check_args(args_to_check = "x", args_type = "character")
  ecokit::check_args(args_to_check = "warning", args_type = "logical")

  if (length(x) != 1L || is.na(x) || !nzchar(x)) {
    ecokit::stop_ctx(
      "`x` must be a non-empty character string of length 1",
      x = x, class_x = class(x), length_x = length(x))
  }

  if (length(warning) != 1L || is.na(warning)) {
    ecokit::stop_ctx(
      "`warning` must be a single logical value",
      warning = warning, class_warning = class(warning))
  }

  pattern <- paste0(
    "^(\\d+-)?([0-9]|[0-1][0-9]|2[0-3])",
    ":[0-5][0-9](:[0-5][0-9])?$|^\\d+$")

  if (stringr::str_detect(x, pattern, negate = TRUE)) {
    if (warning) {
      ecokit::stop_ctx("Invalid SLURM runtime format", x = x)
    }
    base::warning("Invalid SLURM runtime format: `", x, "`", call. = FALSE)
    return(FALSE)
  }

  x
}

## |------------------------------------------------------------------------| #
# validate_slurm_ram ----
## |------------------------------------------------------------------------| #

#' @rdname validators
#' @order 5
#' @export

validate_slurm_ram <- function(x) {

  ecokit::check_args(args_to_check = "x", args_type = "character")

  if (length(x) != 1L || is.na(x) || !nzchar(x)) {
    ecokit::stop_ctx(
      "`x` must be a non-empty character string of length 1",
      x = x, class_x = class(x), length_x = length(x))
  }

  pattern <- "^\\d+(K|M|G|T|KB|MB|GB|TB)$"

  if (stringr::str_detect(x, pattern, negate = TRUE)) {
    ecokit::stop_ctx("Invalid SLURM ram request", x = x)
  }

  x
}

## |------------------------------------------------------------------------| #
# check_java ----
## |------------------------------------------------------------------------| #

#' Check that Java is available on the system PATH
#'
#' Verifies that a `java` executable can be located and invoked from the system
#' shell, by running `java -version` and checking both that the call succeeds
#' and that it returns a zero exit status.
#'
#' @return Invisibly returns `TRUE` if Java is available and callable; otherwise
#'   throws an error, including the captured command output and exit status (if
#'   any) for debugging.
#' @export
#' @author Ahmed El-Gabbas
#' @examples
#' \dontrun{
#'   check_java()
#' }

check_java <- function() {

  result <- tryCatch(
    system2(command = "java", args = "-version", stdout = TRUE, stderr = TRUE),
    error = function(e) NULL,
    warning = function(w) NULL)

  status <- attr(result, "status")

  if (is.null(result) || (!is.null(status) && status != 0L)) {
    ecokit::stop_ctx(
      "Java is not installed or not available on the system PATH.",
      java_output = result, exit_status = status)
  }

  invisible(TRUE)
}
