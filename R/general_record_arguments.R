## |------------------------------------------------------------------------| #
# record_arguments ----
## |------------------------------------------------------------------------| #

#' Capture and record evaluated function arguments
#'
#' `record_arguments()` is a utility function that captures and records the
#' evaluated forms of arguments passed to the parent function. It returns a
#' tibble with columns named after the arguments, containing their evaluated
#' values only.
#'
#' @param out_path Character. The path to an `.RData` file where the output
#'   tibble will be exported. If `NULL` (default), the tibble is returned
#'   without saving. If provided, the tibble is saved to the specified file and
#'   `NULL` is returned invisibly.
#'
#' @return A `tibble` containing the evaluated forms of the parent function’s
#'   arguments and any additional named arguments passed via `...`, with columns
#'   named after the arguments (e.g., `w`, `x`, `y`, `extra1`). Evaluated values
#'   are presented as scalars (e.g., `8`) or list columns for complex objects
#'   (e.g., `<SpatRaster>`). If `out_path` is provided, the tibble is saved to
#'   the specified `.RData` file and `NULL` is returned invisibly.
#'
#' @details This function evaluates all arguments in the grandparent environment
#'   (two frames up), with a fallback to the global environment if evaluation
#'   fails. This ensures correct evaluation in iterative contexts like `lapply`.
#'   It handles:
#' - Scalars (e.g., numbers, strings) as single values.
#' - Multi-element vectors or complex objects (e.g., `SpatRaster`) as list
#'   columns.
#' - `NULL` values are converted to the string `"NULL"`.
#' - Failed evaluations result in `NA`.
#' - Additional named arguments passed via `...` in the parent function are also
#'   recorded.
#'
#'  The function must be called from within another function, as it relies on
#'  `sys.call(-1)` to capture the parent call.
#'
#' @examples
#' a <- 5
#' b <- 3
#' w_values <- 1:3
#' x_values <- c(a + b, 10, 15)
#' y_values <- c("ABCD", "XYZ123", "TEST")
#'
#' Function1 <- function(w = 5, x, y, z = c(1, 2), ...) {
#'   Args <- record_arguments()
#'   return(Args)
#' }
#'
#' # ----------------------------------------------------
#' # Example 1: Simple function call with scalar and expression
#' # ----------------------------------------------------
#'
#' Function1(x = a + b, y = 2)
#'
#' # ----------------------------------------------------
#' # Example 2: Using lapply with indexed arguments
#' # ----------------------------------------------------
#'
#' lapply(
#'   X = 1:3,
#'   FUN = function(Z) {
#'     Function1(
#'       w = w_values[Z],
#'       x = x_values[Z],
#'       y = stringr::str_extract(y_values[Z], "B.+$"),
#'       z = Z)
#' }) %>%
#' dplyr::bind_rows() %>%
#' print()
#'
#' # ----------------------------------------------------
#' # Example 3: Using pmap with mixed argument types
#' # ----------------------------------------------------
#'
#' purrr::pmap(
#'   .l = list(w = w_values, x = x_values, y = y_values),
#'   .f = function(w, x, y) {
#'     Function1(
#'       w = w,
#'       x = x,
#'       y = stringr::str_extract(y, "B.+$"),
#'       z = terra::rast(system.file("ex/elev.tif", package = "terra")))
#'   }) %>%
#'   dplyr::bind_rows() %>%
#'   print()
#'
#' # ----------------------------------------------------
#' # Example 4: Using additional arguments via ...
#' # ----------------------------------------------------
#'
#' Function1(x = a + b, y = "test", extra1 = "hello", extra2 = 42)
#'
#' @author Ahmed El-Gabbas
#' @export
#' @name record_arguments

record_arguments <- function(out_path = NULL) {

  # # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| #
  # Capture the call to the parent function
  # # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| #

  # Use sys.call(-1) to get the call from the parent frame
  call_info <- sys.call(-1)

  # # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| #
  # Validate that record_arguments is called within a function
  # # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| #

  # If call_info is NULL, it means there’s no parent call, so stop execution
  if (is.null(call_info)) {
    ecokit::stop_ctx(
      "`record_arguments` function must be called from within another function",
      call_info = call_info)
  }

  # # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| #
  # Extract key information about the parent function
  # # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| #

  # Get the name of the calling function as a string (e.g., "Function1")
  calling_func <- deparse(call_info[[1]])

  # Set the environment where arguments will be evaluated to the grandparent
  # frame (two levels up, e.g., the environment of the anonymous function in
  # lapply)
  parent_env <- parent.frame(2)

  # Get the parent function object itself
  parent_func <- sys.function(-1)

  # Extract the formal arguments (with defaults) as a named list
  formal_args <- as.list(formals(parent_func))

  # # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| #
  # Define a helper function to merge two lists
  # # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| #

  # Updates 'base_list' with values from 'new_list', including NULLs
  merge_lists <- function(base_list, new_list) {
    # Iterate over all names in the new list
    for (name in names(new_list)) {
      # Assign the value from new_list to base_list, overwriting or adding it
      base_list[[name]] <- new_list[[name]]
    }
    # Return the updated base list
    base_list
  }

  # # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| #
  # Extract and prepare the passed arguments
  # # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| #

  # Get the arguments from the call, excluding the function name (first element)
  passed_args <- as.list(call_info)[-1]
  # Replace any NULL values with the string "NULL" for consistency
  passed_args <- purrr::map(
    .x = passed_args,
    .f = ~ {
      if (is.null(.x)) {
        # Convert NULL to "NULL" string
        "NULL"
      } else {
        # Keep non-NULL values unchanged (e.g., expressions, scalars)
        .x
      }
    })

  # # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| #
  # Combine formal arguments with passed arguments
  # # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| #

  # Merge passed arguments into formal arguments, overriding defaults where
  # provided
  combined_args <- merge_lists(formal_args, passed_args)

  # # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| #
  # Evaluate the combined arguments
  # # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| #

  # Evaluate each argument in the parent environment, with fallback to global
  # environment, converting NULL defaults to scalar "NULL" for tibble
  # compatibility

  evaluated_args <- lapply(combined_args, function(arg) {
    tryCatch(
      # Try evaluating the argument in the grandparent environment
      {
        result <- eval(arg, envir = parent_env)
        if (is.null(result)) {
          # Convert NULL results (e.g., from default arguments) to scalar "NULL"
          "NULL"
        } else {
          result
        }
      },
      error = function(e) {
        # If it fails, try the global environment as a fallback
        tryCatch(
          {
            result <- eval(arg, envir = globalenv())
            if (is.null(result)) {
              # Convert NULL results to scalar "NULL" in fallback case too
              "NULL"
            } else {
              result
            }
          },
          error = function(e2) {
            # Return NA if evaluation fails in both environments
            NA
          })
      })
  })

  # # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| #
  # Name and finalise the evaluated arguments
  # # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| #

  # Assign names to the evaluated values based on the argument names
  named_evaluated_args <- stats::setNames(evaluated_args, names(combined_args))

  # Merge evaluated values back into formal arguments to ensure all args are
  # present
  final_evaluated_args <- merge_lists(formal_args, named_evaluated_args)

  # Replace any NULL values with "NULL" string to maintain consistency
  final_evaluated_args <- purrr::map(
    .x = final_evaluated_args,
    .f = ~ {
      if (is.null(.x)) {
        # Convert NULL to "NULL" string
        "NULL"
      } else {
        # Keep non-NULL values unchanged
        .x
      }
    })

  # # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| #
  # Prepare argument names for the output
  # # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| #

  # Use the original order of argument names from the function definition,
  # excluding '...', and add any additional named arguments from the call
  formal_names <- names(formal_args)[names(formal_args) != "..."]
  passed_names <- names(passed_args)
  passed_names <- passed_names[!is.na(passed_names) & nzchar(passed_names)]
  extra_names <- setdiff(passed_names, formal_names)
  arg_names <- unique(c(formal_names, extra_names))

  # # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| #
  # Format evaluated values for the tibble
  # # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| #

  # Convert values into a format suitable for a tibble (scalars or lists)
  formatted_values <- purrr::map(
    .x = as.list(final_evaluated_args),
    .f = function(value) {
      # Case 1: Simple vectors (not lists)
      if (is.vector(value) && !is.list(value)) {
        if (length(value) == 1) {
          # Scalars (e.g., 5, "NULL") are returned as-is
          return(value)
        } else {
          # Multi-element vectors (e.g., c(1, 2)) are wrapped in a list
          return(list(value))
        }
        # Case 2: Language objects (e.g., unevaluated expressions)
      } else if (is.language(value)) {
        # Evaluate the expression in the grandparent environment
        eval_result <- eval(value, envir = parent_env)
        if (is.vector(eval_result) && !is.list(eval_result) &&
            length(eval_result) == 1) {
          # Scalar results (e.g., 8 from a + b) returned as-is
          return(eval_result)
        } else {
          # Complex results wrapped in a list
          return(list(eval_result))
        }
        # Case 3: SpatRaster objects
      } else if (inherits(value, "SpatRaster")) {
        # Wrap SpatRaster objects in a list for storage
        return(list(terra::wrap(value)))
      } else {
        # Case 4: Any other complex objects (e.g., lm models)
        return(list(value))
      }
    })

  # # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| #
  # Build the output tibble
  # # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| #

  # Create a named list of formatted values using the argument names
  tibble_data <- stats::setNames(formatted_values[arg_names], arg_names)

  # Construct a one-row tibble from the formatted data
  result <- tibble::as_tibble(tibble_data, .rows = 1)

  # # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| #
  # Handle output based on out_path
  # # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| #

  if (is.null(out_path)) {
    # If no export path is provided, return the tibble directly
    return(result)
  } else {
    # Remove any namespace prefix from the calling function name
    calling_func_clean <- stringr::str_remove(calling_func, "^.+::")
    # Save the tibble to an .RData file with a descriptive name
    ecokit::save_as(
      object = result,
      object_name = paste0("Args_", calling_func_clean),
      out_path = out_path)
    # Return NULL invisibly after saving
    return(invisible(NULL))
  }
}
