## |------------------------------------------------------------------------| #
# save_session ----
## |------------------------------------------------------------------------| #

#' Save non-function objects from the global environment to an RData file
#'
#' Saves all objects (except functions and specified exclusions) from the global
#' environment as a named list in an `.RData` file. Returns a summary of the
#' saved objects' sizes in memory.
#'
#' @param out_directory Character. Directory path where the `.RData` file is
#'   saved. Defaults to the current working directory [base::getwd()].
#' @param exclude_objects Character vector. Names of objects to exclude from
#'   saving. Defaults to `NULL`.
#' @param prefix Character. Prefix for the saved file name. Defaults to `"S"`.
#' @return A tibble with columns `object` (object names) and `size` (size in MB,
#'   rounded to 1 decimal place) for the saved objects, sorted by size in
#'   descending order.
#' @export
#' @name save_session
#' @examples
#' load_packages(fs, purrr)
#'
#' # Create sample objects in the global environment
#' assign("df", data.frame(a = 1:1000), envir = .GlobalEnv)
#' assign("vec", rnorm(1000), envir = .GlobalEnv)
#' assign("fun", function(x) x + 1, envir = .GlobalEnv)
#' ls(.GlobalEnv)
#'
#' # Save objects to a unique temporary directory, excluding "vec"
#' temp_dir <- fs::path_temp("save_session")
#' fs::dir_create(temp_dir)
#'
#' (result <- save_session(out_directory = temp_dir, exclude_objects = "vec"))
#'
#' # Load saved objects
#' saved_files <- list.files(
#'   temp_dir, pattern = "S_.+\\.RData$", full.names = TRUE)
#' if (length(saved_files) == 0) {
#'   stop("No RData files found in temp_dir")
#' }
#' # pick the most recent file, if there is more than one file
#' (saved_file <- saved_files[length(saved_files)])
#'
#' saved_objects <- ecokit::load_as(saved_file)
#' names(saved_objects)
#' str(saved_objects, 1)
#'
#' setdiff(
#'   ls(.GlobalEnv),
#'   c(result$object, "saved_file", "result", "saved_objects", "temp_dir")) %>%
#'   purrr::map(~ stats::setNames(class(get(.x, envir = .GlobalEnv)), .x)) %>%
#'   unlist()
#'
#' # Clean up
#' fs::dir_delete(temp_dir)

## |------------------------------------------------------------------------| #
# save_session ----
## |------------------------------------------------------------------------| #

save_session <- function(
    out_directory = getwd(), exclude_objects = NULL, prefix = "S") {

  # Avoid "no visible binding for global variable" message
  # https://www.r-bloggers.com/2019/08/no-visible-binding-for-global-variable/
  object <- class <- size <- NULL

  # Input validation
  if (!is.character(out_directory) || length(out_directory) != 1L) {
    ecokit::stop_ctx("`out_directory` must be a single character string")
  }
  if (!is.character(prefix) || length(prefix) != 1L) {
    ecokit::stop_ctx("`prefix` must be a single character string")
  }

  # Create output directory if it doesn't exist
  fs::dir_create(out_directory)

  # Default exclusions for specific objects
  default_exclusions <- c(
    "Grid_10_sf_s", "Grid_10_Raster", "Bound_sf_Eur_s", "Bound_sf_Eur")
  exclude_objects <- unique(c(exclude_objects, default_exclusions))

  # Get all objects from the global environment
  all_objects <- ls(envir = .GlobalEnv)

  valid_objects <- tibble::tibble(object = all_objects) %>%
    dplyr::mutate(
      class = purrr::map_chr(
        .x = object,
        .f = ~ {
          obj <- get(.x, envir = .GlobalEnv)
          if (typeof(obj) == "function") "function" else class(obj)[1L]
        }
      )) %>%
    dplyr::filter(class != "function", !(object %in% exclude_objects)) %>%
    dplyr::pull(object)

  # Handle empty case
  if (length(valid_objects) == 0L) {
    warning("No valid objects to save after filtering", call. = FALSE)
    return(tibble::tibble(object = character(), size = numeric()))
  }

  # Wrap SpatRaster objects and prepare the list
  object_list <- purrr::map(
    .x = valid_objects,
    .f = ~ {
      obj <- get(.x, envir = .GlobalEnv)
      if (inherits(obj, "SpatRaster")) {
        suppressWarnings(terra::wrap(obj))
      } else {
        obj
      }
    }) %>%
    stats::setNames(valid_objects)

  # Generate timestamped file name
  timestamp <- lubridate::now(tzone = "CET") %>%
    format("%Y%m%d_%H%M") %>%
    paste0(prefix, "_", .)
  out_path <- fs::path(out_directory, timestamp, ext = "RData")

  # Save named list of objects to RData file
  ecokit::save_as(
    object = object_list, object_name = timestamp, out_path = out_path)

  message("Saved objects to:\n", crayon::blue(out_path))

  # Calculate object sizes and return summary
  output <- tibble::tibble(
    object = names(object_list),
    size = purrr::map_dbl(object_list, lobstr::obj_size)) %>%
    dplyr::mutate(size = round(size / (1024L * 1024L), 1L)) %>%
    dplyr::arrange(dplyr::desc(size))

  return(output)
}
