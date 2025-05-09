## |------------------------------------------------------------------------| #
# script_location ----
## |------------------------------------------------------------------------| #

#' Retrieve the location of the current R script.
#'
#' This function determines the file path of the currently executing R script.
#' It checks command line arguments (e.g., via `Rscript`) for the script path,
#' then in interactive sessions, it examines the call stack for the most
#' recently sourced file, falling back to `rstudioapi` (if available and RStudio
#' is running) when no sourcing context exists. If the location cannot be
#' determined, it returns `NA`.
#'
#' @return A character string representing the file path of the current R
#'   script, or `NA_character_` if the path cannot be determined (e.g., in an
#'   unsourced interactive session without a script context).
#'
#' @details The function follows this priority order:
#' - Command line arguments (`--file`) when executed via `Rscript`.
#' - The most recent `ofile` attribute from the call stack when sourced
#'   interactively in any R environment, supporting nested sourcing scenarios.
#' - RStudio's active editor context via `rstudioapi` if available, RStudio is
#'   running, and no sourcing context is found.
#' - Returns `NA_character_` for unsourced interactive sessions or
#'   non-interactive execution without a script path.
#'
#' @name script_location
#' @source The source code of this function was adapted from this
#'   [stackoverflow](https://stackoverflow.com/questions/47044068/) question.
#' @importFrom rlang .data
#' @export
#' @examples
#' \dontrun{
#'   # in an interactive mode, use
#'   script_location()
#'
#'   # add script_location() to your script; e.g. "my_script.R"
#'   # Run: Rscript my_script.R
#'   # Output: absolute path of the script
#' }

script_location <- function() {

  # Attempt to extract the script path from command line arguments (e.g.,
  # Rscript)
  this_file <- commandArgs() %>%
    # Convert to a tibble with a single column 'value'
    tibble::enframe(name = NULL) %>%
    # Split each argument at '=' into 'key' and 'value'
    tidyr::separate(
      col = .data$value, into = c("key", "value"),
      sep = "=", fill = "right") %>%
    # Keep only the '--file' argument
    dplyr::filter(.data$key == "--file") %>%
    # Extract the value (file path)
    dplyr::pull(.data$value)

  if (length(this_file) > 0L) {
    # If a command-line file path is found (e.g., from Rscript), use it. This
    # handles cases like 'Rscript my_script.R'
    this_file <- this_file
  } else if (interactive()) {
    # If running interactively (R console, RStudio, etc.), check the call stack
    # for sourced script paths
    frame_files <- lapply(
      X = sys.frames(),
      FUN = function(x) {
        # For each frame, check if 'ofile' exists (set by source()) and retrieve
        # it
        if (exists("ofile", envir = x)) {
          get("ofile", envir = x)
        } else {
          NULL
        }
      })

    # Flatten the list, removing NULLs
    valid_files <- unlist(frame_files)
    if (length(valid_files) > 0L && any(nzchar(valid_files))) {
      # If valid file paths are found, take the most recent one (last in stack).
      # This ensures nested sourcing returns the innermost script (e.g., TT2.R)
      this_file <- utils::tail(valid_files[nzchar(valid_files)], 1L)
    } else if (requireNamespace("rstudioapi", quietly = TRUE) &&
               rstudioapi::isAvailable()) {
      # If no sourced files are found and RStudio is available, use the active
      # editor context as a fallback (useful for unsourced code in RStudio)
      this_file <- tryCatch(
        # Get path of active script in RStudio
        rstudioapi::getSourceEditorContext()$path,
        # Return NA if RStudio call fails
        error = function(e) NA_character_)
    } else {
      # No sourced files and not in RStudio: return NA (e.g., console without
      # source)
      this_file <- NA_character_
    }
  } else {
    # Non-interactive session without command-line args (unlikely case): return
    # NA
    this_file <- NA_character_
  }

  # Return the determined file path or NA
  ecokit::normalize_path(this_file)
}
