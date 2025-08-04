## |------------------------------------------------------------------------| #
# all_objects_sizes ----
## |------------------------------------------------------------------------| #

#' Size of objects in memory
#'
#' This function calculates the size of objects in the global environment of R
#' using [lobstr::obj_size] and prints a summary of objects that are greater
#' than a specified size threshold. It is useful for memory management and
#' identifying large objects in the workspace.
#' @param greater_than Numeric. Size threshold in MB. Only objects larger than
#'   this value will be shown. Default is 0, which means all objects will be
#'   shown. `greater_than` must be a non-negative number.
#' @param in_function Logical. This controls the scope of the function. It
#'   indicates whether the execution is done inside or outside of a function.
#'   Defaults to `FALSE` to show sizes of objects in the global environment. If
#'   set to `TRUE`, sizes of objects in the function are returned.
#' @param n_decimals Integer; representing the number of decimal places to
#'   show in the `size_mb` column. Defaults to 2.
#' @param n_objects Number of objects to show. Defaults to `Inf` meaning show
#'   all available objects.
#' @return The function prints a tibble containing the variables' names, their
#'   sizes in MB, and their percentage of the total size of all variables. If no
#'   objects meet the criteria, a message is printed instead. Output is sorted
#'   in descending order of the size of the objects. The function also prints
#'   the total size of all variables and the number of objects that were
#'   examined.
#' @author Ahmed El-Gabbas
#' @importFrom rlang .data
#' @export
#' @name all_objects_sizes
#' @examples
#' AA1 <<- rep(seq_len(1000), 10000)
#' AA2 <<- rep(seq_len(1000), 100)
#'
#' # ----------------------------------------------------
#' # All objects in memory
#' # ----------------------------------------------------
#'
#' all_objects_sizes()
#'
#'
#' # ----------------------------------------------------
#' # Objects larger than 1 MB
#' # ----------------------------------------------------
#'
#' all_objects_sizes(greater_than = 1)
#'
#'
#' # ----------------------------------------------------
#' # Objects larger than 50 MB
#' # ----------------------------------------------------
#'
#' all_objects_sizes(greater_than = 50)
#'
#'
#' # ----------------------------------------------------
#' # When called with another function, it shows the objects only available
#' # within the function
#' # ----------------------------------------------------
#'
#' TestFun <- function(XX = 10) {
#'   Y <- 20
#'   C <- matrix(data = seq_len(10000), nrow = 100, ncol = 100)
#'   all_objects_sizes(in_function = TRUE)
#' }
#'
#' TestFun()
#'
#' TestFun(XX = "TEST")

all_objects_sizes <- function(
    greater_than = 0L, in_function = FALSE, n_decimals = 2L, n_objects = Inf) {

  if (!requireNamespace("lobstr", quietly = TRUE)) {
    ecokit::stop_ctx(
      "The `lobstr` package is required to calculate object sizes.")
  }

  if (!requireNamespace("withr", quietly = TRUE)) {
    ecokit::stop_ctx(
      "The `withr` package is required to manage temporary options.")
  }

  if (in_function) {
    current_environment <- parent.frame()
  } else {
    current_environment <- .GlobalEnv
  }

  if (!is.numeric(greater_than) || is.na(greater_than) || greater_than < 0L) {
    ecokit::stop_ctx(
      "`greater_than` must be a non-negative number",
      greater_than = greater_than)
  }

  all_variables <- ls(envir = current_environment, all.names = TRUE)

  if (length(all_variables) == 0L) {
    cat("No Objects are available in the global environment!\n")
  } else {

    all_vars_size <- purrr::map_dfr(
      .x = all_variables,
      .f = ~{
        object <- get(.x, envir = current_environment)
        object_class <- paste(class(object), collapse = "_")

        tryCatch({
          size_mb <- lobstr::obj_size(object) / (1024L * 1024L)
          size_mb <- round(as.numeric(size_mb), n_decimals)
          return(
            tibble::tibble(
              object = .x, object_class = object_class,
              size_mb = size_mb))

        }, error = function(e) {
          tibble::tibble(
            object = .x, object_class = object_class, size_mb = NA_real_)
        })
      }) %>%
      dplyr::mutate(
        percent = round(
          100L * .data$size_mb / sum(.data$size_mb, na.rm = TRUE), 2L)) %>%
      dplyr::arrange(dplyr::desc(.data$size_mb)) %>%
      dplyr::filter(
        .data$size_mb >= greater_than | is.na(.data$size_mb))

    if (nrow(all_vars_size) > 0L) {
      cat(crayon::blue(
        "---------------------------------------------------\n\t",
        crayon::bold(sum(!is.na(all_vars_size$size_mb))),
        " object(s) fulfil the criteria\n",
        "---------------------------------------------------\n",
        sep = ""),
        sep = "")

      withr::local_options(list(pillar.sigfig = 4L))
      print(all_vars_size, n = n_objects)

      if (sum(is.na(all_vars_size$size_mb)) > 0L) {
        na_var <- all_vars_size %>%
          dplyr::filter(is.na(.data$size_mb)) %>%
          dplyr::pull(.data$object) %>%
          paste(collapse = " | ")

        cat(crayon::blue(
          paste0(
            "`lobstr::obj_size` was not able to get the object ",
            "size of the following object(s): ", na_var, "\n"), sep = ""),
          sep = "")
      }
    } else {
      cat(crayon::red(
        paste0("No object has Size > ", greater_than, " MB\n")), sep = "")
    }
  }
}
