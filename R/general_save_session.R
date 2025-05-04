## |------------------------------------------------------------------------| #
# save_session ----
## |------------------------------------------------------------------------| #

#' Saves all non-function objects from the global environment to an RData file
#'
#' This function saves all objects (except functions and specified exclusions)
#' from the global environment as list items in an `RData` file. It also creates
#' a summary of these objects' sizes in memory.
#'
#' @param out_directory Character. Directory path where the output `RData` file
#'   should be saved. Defaults to the current working directory [base::getwd()].
#' @param exclude_objects Character vector. Object names (as strings) to exclude
#'   from saving.
#' @param prefix Character. prefix the saved file name with. Defaults to `S`.
#' @author Ahmed El-Gabbas
#' @return A tibble containing the names and sizes (in MB, rounded to 1 decimal
#'   place) of the saved objects.
#' @export
#' @name save_session

save_session <- function(
  out_directory = getwd(), exclude_objects = NULL, prefix = "S") {

  # Avoid "no visible binding for global variable" message
  # https://www.r-bloggers.com/2019/08/no-visible-binding-for-global-variable/
  object <- class <- size <- object2 <- NULL

  fs::dir_create(out_directory)

  # Also exclude some common use objects
  exclude_objects <- c(
    exclude_objects, "Grid_10_sf_s", "Grid_10_Raster",
    "Bound_sf_Eur_s", "Bound_sf_Eur")

  all_objects <- ls(envir = .GlobalEnv) %>%
    tibble::tibble(object = .) %>%
    dplyr::mutate(
      class = purrr::map_chr(
        .x = object,
        .f = ~{
          get(.x, envir = .GlobalEnv) %>%
            class() %>%
            stringr::str_c(collapse = "_")
        }
      )) %>%
    dplyr::filter(class != "function", !(object %in% exclude_objects)) %>%
    dplyr::pull(object)

  all_objects <- purrr::map(
      .x = all_objects,
      .f = ~{
        object2 <- get(.x, envir = .GlobalEnv)
        if (class(object2)[1] == "SpatRaster") {
          suppressWarnings(terra::wrap(object2))
        } else {
          object2
        }
      }) %>%
    stats::setNames(all_objects)

  ff_2 <- purrr::map_chr(
      .x = lubridate::now(tzone = "CET"),
      .f = ~{
        c(lubridate::year(.x), lubridate::month(.x),
          lubridate::day(.x), "__",
          lubridate::hour(.x), lubridate::minute(.x)) %>%
          purrr::map_chr(stringr::str_pad, width = 2, pad = "0") %>%
          stringr::str_c(collapse = "") %>%
          stringr::str_replace_all("__", "_") %>%
          stringr::str_c(prefix, "_", ., collapse = "_")
      })

  ecokit::save_as(
    object = all_objects, object_name = ff_2,
    out_path = ecokit::path(out_directory, paste0(ff_2, ".RData")))

  output <- all_objects %>%
    lapply(lobstr::obj_size) %>%
    tibble::tibble(object2 = names(.), size = as.numeric(.)) %>%
    dplyr::mutate(size = size / (1024 * 1024), size = round(size, 1)) %>%
    dplyr::select(object2, size) %>%
    dplyr::arrange(dplyr::desc(size))

  return(output)
}
