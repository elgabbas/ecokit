## |------------------------------------------------------------------------| #
# stop_ctx ----
## |------------------------------------------------------------------------| #

#' Signal structured errors with metadata, timestamps, and backtraces
#'
#' Signals errors with rich context, wrapping [rlang::abort()]. It includes:
#' - The calling function name (if applicable).
#' - User-defined metadata (e.g., vectors, lists, data frames, tibbles,
#' terra::SpatRaster, raster::Raster, RasterStack, RasterBrick, sf objects,
#' regression models, ggplot objects, S4 objects).
#' - Optional timestamps/dates.
#' - Optional backtraces to aid debugging.
#'
#' @param message Character. The primary error message to display.
#' @param ... Named R objects to include as metadata. These can be of various
#'   types, such as vectors, lists, data frames, tibbles, terra::SpatRaster,
#'   raster::Raster, RasterStack, RasterBrick, sf objects, regression models
#'   (e.g., lm, glm), ggplot objects, S4 objects, and more. Unnamed arguments
#'   will cause an error due to `.named = TRUE` in [rlang::enquos()]. `NULL`
#'   values are displayed as "NULL".
#' @param class Character or NULL. Subclass(es) for the error condition.
#'   Defaults to NULL.
#' @param call Call or NULL. The call causing the error. Defaults to the
#'   caller's expression.
#' @param parent Condition or NULL. Parent error for nesting. Defaults to NULL.
#' @param include_backtrace Logical. If `TRUE`, includes a compact backtrace.
#'   Default: `TRUE`.
#' @param cat_timestamp Logical. If `TRUE`, prepends a timestamp (HH:MM:SS).
#'   Default: `TRUE`.
#' @param cat_date Logical. If `TRUE`, prepends the date (YYYY-MM-DD). Default:
#'   `FALSE`.
#' @return Does not return; throws an error via [rlang::abort()].
#' @importFrom rlang %||%
#' @export
#' @author Ahmed El-Gabbas
#' @section Metadata Output: The metadata section in the error message displays
#'   each provided object with its name, the verbatim expression used, its
#'   class, and its value:
#'   \itemize{
#'     \item \strong{Object Name}: The name of the argument (e.g., `file`).
#'     \item \strong{Verbatim Expression}: The expression passed (e.g.,
#'       `"data.csv"`).
#'     \item \strong{Class}: The class of the object, with multiple classes
#'       concatenated using ` + ` (e.g., `<tbl_df + tbl + data.frame>`).
#'     \item \strong{Value}: The formatted output of the object, using methods
#'       like `print()`, `summary()`, `glimpse()`, or `str()`, depending on the
#'       object type.
#'   }
#'   For example:
#'   \preformatted{
#'   ----- Metadata -----
#'   file ["data.csv"]: <character>
#'   "data.csv"
#'
#'   type ["missing_input"]: <character>
#'   "missing_input"
#'   }
#'   Complex objects, such as data frames or raster layers, will display their
#'   structure or summary as appropriate.
#'
#' @examples
#' # Basic error with metadata
#' try(
#'   stop_ctx(
#'     message = "File not found", file = "data.csv",
#'     type = "missing_input", foo = 1:3))
#'
#' # -------------------------------------------------------------------
#'
#' # Include date in error message
#' try(
#'   stop_ctx(
#'     message = "File not found", file = "data.csv",
#'     type = "missing_input", cat_date = TRUE))
#'
#' # -------------------------------------------------------------------
#'
#' # Complex objects as metadata
#' terra_obj <- terra::rast()
#' raster_obj <- raster::raster()
#' sf_obj <- sf::st_point(c(0,0))
#' lm_obj <- lm(mpg ~ wt, data = mtcars)
#' try(
#'   stop_ctx(
#'     message = "File not found", raster = raster_obj, terra = terra_obj,
#'     data_frame = iris, matrix = as.matrix(iris), sf_obj = sf_obj,
#'     lm_obj = lm_obj))
#'
#' # -------------------------------------------------------------------
#'
#' # Error without backtrace
#' try(
#'   stop_ctx(message = "Simple error", include_backtrace = FALSE))
#'
#' # -------------------------------------------------------------------
#'
#' # S4 object as metadata
#' setClass("Student", slots = list(name = "character", age = "numeric"))
#' student <- new("Student", name = "John Doe", age = 23)
#' try(
#'   stop_ctx(
#'     message = "Student record error",
#'     metadata = student, type = "invalid_data"))
#'
#' # -------------------------------------------------------------------
#'
#' # Nested function error with backtrace
#' f3 <- function(x) {
#'   stop_ctx("Non-numeric input in f3()", input = x, include_backtrace = TRUE)
#' }
#' f2 <- function(y) f3(y + 1)
#' f1 <- function(z) f2(z * 3)
#'
#' # Output includes: "Calling Function: f1" before metadata
#' try(f1("not a number"))
#'
#' # -------------------------------------------------------------------
#'
#' # Nested function error without metadata
#' f3 <- function() stop_ctx(message = "Error in f3()")
#' f2 <- function(y) f3()
#' f1 <- function(z) f2()
#'
#' # Output includes: "Calling Function: f1" before metadata
#' try(f1())
#'

stop_ctx <- function(
    message, ..., class = NULL, call = NULL, parent = NULL,
    include_backtrace = TRUE, cat_timestamp = TRUE, cat_date = FALSE) {

  # --------------------------------------------------------------------------
  # 1. Validate flag arguments are logical
  # --------------------------------------------------------------------------

  all_arguments <- ls(envir = environment())
  all_arguments <- purrr::map(
    all_arguments,
    function(x) get(x, envir = parent.env(env = environment()))) %>%
    stats::setNames(all_arguments)

  # Validate that include_backtrace, cat_timestamp, cat_date are logical
  ecokit::check_args(
    args_all = all_arguments, args_type = "logical",
    args_to_check = c("include_backtrace", "cat_timestamp", "cat_date"))
  rm(all_arguments, envir = environment())

  # --------------------------------------------------------------------------
  # 2. Helper functions
  # --------------------------------------------------------------------------

  # Helper: remove blank lines from a character vector
  trim_empty_lines <- function(lines) {
    lines <- lines[nzchar(lines)]
    if (length(lines) == 0) return(character())
    lines
  }

  # # ..................................................................... ###

  # convert objects to string representations
  format_arg <- function(x, name = NULL) {

    # Check if the input is NULL and return "NULL" if true
    if (is.null(x)) {
      return("NULL")
    }

    # Handle objects using print()
    classes_print <- c(
      "lm", "glm", "glmmTMB", "lmerMod", "Hmsc", "RasterLayer",
      "SpatRaster", "Raster", "RasterStack", "RasterBrick")
    if (inherits(x, classes_print)) {
      return(paste(
        trim_empty_lines(utils::capture.output(print(x))), collapse = "\n"))
    }

    # Handle objects using summary()
    classes_summary <- c(
      "mcmc.list", "SpatialPoints", "SpatialPolygons", "SpatialLines")
    if (inherits(x, classes_summary) || isS4(x)) {
      return(
        paste(
          trim_empty_lines(utils::capture.output(summary(x))), collapse = "\n"))
    }


    # Handle objects using glimpse()
    if (is.matrix(x) || is.data.frame(x) || inherits(x, "tbl_df") ||
        inherits(x, "tibble")) {
      return(
        paste(
          trim_empty_lines(
            utils::capture.output(dplyr::glimpse(x))), collapse = "\n"))
    }

    # Handle objects using str()
    if (inherits(x, c("ts", "gg", "function"))) {
      return(
        paste(
          trim_empty_lines(
            utils::capture.output(
              utils::str(x, max.level = 1, give.attr = FALSE))),
          collapse = "\n"))
    }

    # Handle atomic vectors with length > 1 by collapsing
    if (is.atomic(x) && length(x) > 1) {
      return(toString(x))
    }

    # Handle lists: collapse if atomic, else use str
    if (is.list(x)) {
      # Check if all elements are atomic
      if (all(vapply(x, is.atomic, logical(1)))) {
        return(toString(unlist(x)))
      }
      # Use str for non-atomic lists
      return(
        paste(
          trim_empty_lines(
            utils::capture.output(
              utils::str(x, max.level = 1, give.attr = FALSE))),
          collapse = "\n"))
    }

    # Fallback: base format()
    return(format(x))
  }

  # --------------------------------------------------------------------------
  # 3. Capture and evaluate metadata arguments
  # --------------------------------------------------------------------------

  # Capture named arguments as quosures, enforcing named arguments
  quos <- rlang::enquos(..., .named = TRUE)
  # Extract labels for each quosure
  labels <- lapply(quos, rlang::as_label)
  # Initialise a named list to store evaluated values
  vals <- vector("list", length(quos))
  # Set names of the list to match quosure names
  names(vals) <- names(quos)

  # Loop through each named quosure to evaluate it
  for (nm in names(quos)) {
    # Evaluate the quosure and handle potential errors
    vals[[nm]] <- tryCatch(
      # Evaluate the quosure in its environment
      rlang::eval_tidy(quos[[nm]]),
      error = function(e) {
        # Re-signal error with context if evaluation fails
        stop_ctx(
          message = paste0(
            "Error evaluating argument '", nm, "': ", conditionMessage(e)),
          class = class, call = call, parent = e,
          include_backtrace = include_backtrace, cat_timestamp = cat_timestamp,
          cat_date = cat_date)
      })
  }

  # --------------------------------------------------------------------------
  # 4. Build a formatted metadata string
  # --------------------------------------------------------------------------

  # Initialise an empty string for metadata
  metadata_str <- ""

  # Check if there are metadata values to process
  if (length(vals)) {
    # Format each metadata entry with key, label, class, and value
    blocks <- mapply(function(key, lbl, val) {

      # Show class in `<c1 + c2>` form, or "NULL"
      obj_class <- if (is.null(val)) {
        "NULL"
      } else {
        paste0("<", paste(class(val), collapse = " + "), ">")
      }

      # Combine key (bold, blue), label, class, and formatted value
      paste0(
        crayon::blue(crayon::bold(key)), " [", crayon::underline(lbl),
        "]: ", obj_class, "\n",
        format_arg(val, key))
    },
    names(vals), labels, vals, SIMPLIFY = TRUE)
    # Join formatted blocks with double newlines
    metadata_str <- paste(blocks, collapse = "\n\n")
  }

  # --------------------------------------------------------------------------
  # 5. Capture name of calling function
  # --------------------------------------------------------------------------

  # Initialise calling function name as NULL
  caller_name <- NULL

  # Get all calls in the stack
  calls <- sys.calls()
  n_calls <- length(calls)

  # Traverse the stack from top to bottom, excluding stop_ctx itself, only if
  # there are calls
  if (n_calls > 1) {
    for (i in 1:(n_calls - 1)) {
      call <- calls[[i]]
      if (is.symbol(call[[1]])) {  # Ensure the call has a named function
        fn_name <- as.character(call[[1]])
        # Determine the environment where the call was made
        if (i == 1) {
          envir <- globalenv()  # Top-level call is from global environment
        } else {
          envir <- sys.frame(i - 1)  # Parent frame of the call
        }
        # Try to get the function object
        func <- try(get(fn_name, envir = envir), silent = TRUE)
        if (is.function(func)) {
          func_env <- environment(func)
          if (identical(func_env, globalenv()) && fn_name != "stop_ctx") {
            caller_name <- fn_name  # Found the outermost user-defined function
            break
          }
        }
      }
    }
  }

  # Format caller name for display only if caller_name is not NULL and not empty
  caller_str <- if (!is.null(caller_name) && nzchar(caller_name)) {
    paste0(
      "----- Calling Function -----\n",
      crayon::blue(crayon::bold(caller_name)))
  } else {
    ""
  }

  # --------------------------------------------------------------------------
  # 6. Capture an inline backtrace if requested
  # --------------------------------------------------------------------------

  # Initialise backtrace as NULL
  backtrace_info <- NULL

  # Check if backtrace is requested
  if (include_backtrace) {
    # Capture the call stack, starting from the second frame
    trace <- rlang::trace_back(bottom = 2)
    # Capture the printed backtrace output
    trace_out <- utils::capture.output(print(trace))
    # Include backtrace if it has content beyond the header
    if (length(trace_out) > 1) {
      # Join backtrace lines, excluding the first line
      backtrace_info <- paste(trace_out[-1], collapse = "\n")
    }
  }

  # --------------------------------------------------------------------------
  # 7. Format error message with optional timestamp/date
  # --------------------------------------------------------------------------

  # Check if timestamp or date is requested
  if (cat_timestamp || cat_date) {
    ts_lines <- ecokit::cat_time(
      text = message, cat_date = cat_date, cat_timestamp = cat_timestamp) %>%
      utils::capture.output()
    # Format message in bold red
    msg_lines <- crayon::bold(crayon::red(ts_lines))
  } else {
    # Format message in bold red without timestamp/date
    msg_lines <- crayon::bold(crayon::red(message))
  }

  # --------------------------------------------------------------------------
  # 8. Assemble the complete error message
  # --------------------------------------------------------------------------

  full_msg <- c(
    msg_lines,
    # Add calling function name if present
    if (nzchar(caller_str[1])) c("", caller_str),
    # Add metadata section if present
    if (nzchar(metadata_str)) c("", "----- Metadata -----\n", metadata_str),
    if (!is.null(backtrace_info)) {
      c("", "----- Backtrace -----", backtrace_info)
    })

  # Join all parts with newlines
  full_msg <- paste(full_msg, collapse = "\n")

  # --------------------------------------------------------------------------
  # 9. Disable RStudio's browse-on-error temporarily
  # --------------------------------------------------------------------------

  # Store current error option
  prev_err_opt <- getOption("error")
  # Store current rlang backtrace option
  prev_bt_opt  <- getOption("rlang_backtrace_on_error")

  # Disable error browsing and rlang backtrace
  options(error = NULL, rlang_backtrace_on_error = "none")

  # Restore options on exit
  on.exit(
    options(error = prev_err_opt, rlang_backtrace_on_error = prev_bt_opt),
    add = TRUE)

  # --------------------------------------------------------------------------
  # 10. Signal the structured error
  # --------------------------------------------------------------------------

  # Call rlang::abort with the formatted message and metadata
  rlang::abort(
    message = full_msg, ..., class = class, call = call, parent = parent)
}
