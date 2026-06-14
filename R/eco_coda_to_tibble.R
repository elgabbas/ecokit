# # ------------------------------------------------------------------------- #
# coda_to_tibble ----
# # ------------------------------------------------------------------------- #

#' Convert an MCMC coda object to a tidy tibble
#'
#' Converts an object of class `mcmc.list` or `mcmc` — as produced by
#' [coda::as.mcmc.list()] or [Hmsc::convertToCodaObject()] — into a tidy tibble.
#' Four posterior parameter types used in hierarchical models are supported:
#' `"rho"`, `"alpha"`, `"beta"`, and `"omega"`.
#'
#' @param coda_object An object of class `mcmc.list` or `mcmc`. Cannot be
#'   `NULL`.
#' @param posterior_type Character string (case-insensitive). One of `"rho"`,
#'   `"alpha"`, `"beta"`, or `"omega"`. Determines the reshaping and
#'   column-naming strategy applied to the raw MCMC matrix.
#' @param n_omega Positive integer. For `posterior_type = "omega"` only: the
#'   number of species-pair columns to randomly sample from the coda object
#'   before pivoting. If `n_omega` exceeds the number of available columns, all
#'   columns are used and a warning is issued. Default: `100L`.
#'
#' @details Each `posterior_type` produces a different tibble structure:
#' - **`"rho"`**: Returns a tibble with columns `chain`, `iter`, and `value`.
#' - **`"alpha"`**: Returns a tibble with columns `Alpha`, `alpha_num`,
#'   `factor`, `chain`, `iter`, and `value`. Column names in the coda object
#'   must follow the pattern `Alpha<N>[<num>, factor<k>]`.
#' - **`"beta"`**: Returns a nested tibble grouped by `variable` and `sp_id`
#'   (species identifier). Coda dimnames must follow the Hmsc convention
#'   `B[<covariate>, <species_id>]`. Polynomial terms encoded as
#'   `stats::poly(..., degree = 2, raw = TRUE)` are parsed and renamed with `_l`
#'   (linear) and `_q` (quadratic) suffixes.
#' - **`"omega"`**: Samples `n_omega` species pairs at random and returns a
#'   nested tibble grouped by `species_combs`, `sp1`, and `sp2`. Coda dimnames
#'   must follow the Hmsc convention `Omega1[<sp_id1>, <sp_id2>]`.
#'
#' @return A tibble whose structure depends on `posterior_type`; see Details.
#'
#' @seealso [coda::as.mcmc.list()], [Hmsc::convertToCodaObject()]
#' @export
#' @examples
#' #' # Example usage with a coda object from Hmsc::convertToCodaObject()
#' ecokit::load_packages(Hmsc, coda, dplyr)
#'
#' coda_object <- Hmsc::convertToCodaObject(Hmsc::TD$m)
#'
#' # ||||||||||||||||||||||||||||||||||||
#' # Alpha posterior samples
#' # ||||||||||||||||||||||||||||||||||||
#'
#' dt_alpha <- coda_to_tibble(
#'    coda_object = coda_object$alpha[[1]], posterior_type = "Alpha")
#' dplyr::glimpse(dt_alpha)
#'
#' # ||||||||||||||||||||||||||||||||||||
#' # Omega posterior samples
#' # ||||||||||||||||||||||||||||||||||||
#'
#' dt_omega <- coda_to_tibble(
#'    coda_object = coda_object$Omega[[1]], posterior_type = "omega",
#'    n_omega = 10L)
#'
#' dplyr::glimpse(dt_omega)
#'
#' dplyr::glimpse(dt_omega$data[[1]])
#'
#' # ||||||||||||||||||||||||||||||||||||
#' # Rho posterior samples
#' # ||||||||||||||||||||||||||||||||||||
#'
#' dt_rho <- coda_to_tibble(
#'     coda_object = coda_object$rho, posterior_type = "rho")
#' dplyr::glimpse(dt_rho)
#'
#' @author Ahmed El-Gabbas

coda_to_tibble <- function(
    coda_object = NULL, posterior_type = NULL, n_omega = 100L) {


  Alpha <- CHAIN <- ITER <- alpha_num <- chain <- iter <- sp1 <- sp2 <- sp_id <-
    species_combs <- value <- var_sp <- variable <- NULL

  # Validate n_omega
  ecokit::check_args(args_to_check = "n_omega", args_type = "numeric")
  if (!ecokit::is_integer(n_omega) || n_omega <= 0L) {
    ecokit::stop_ctx(
      "`n_omega` must be a positive integer.", n_omega = n_omega)
  }

  # Validate coda_object
  if (is.null(coda_object)) {
    ecokit::stop_ctx("`coda_object` must both be provided.")
  }

  # Accept both mcmc and mcmc.list; coda functions generally handle both,
  # but making this explicit prevents cryptic failures downstream.
  if (!(inherits(coda_object, "mcmc.list") ||
        inherits(coda_object, "mcmc"))) {
    ecokit::stop_ctx(
      "`coda_object` must be of class `mcmc.list` or `mcmc`.",
      class_coda_object = class(coda_object))
  }

  # Validate posterior_type
  if (is.null(posterior_type)) {
    ecokit::stop_ctx("`posterior_type` must both be provided.")
  }

  # Normalise to lower-case so the caller can write "Beta", "beta", "BETA".
  posterior_type <- tolower(posterior_type)
  if (!posterior_type %in% c("rho", "alpha", "omega", "beta")) {
    ecokit::stop_ctx(
      "`posterior_type` must be one of: 'rho', 'alpha', 'omega', or 'beta'.",
      coda_object = coda_object, posterior_type = posterior_type)
  }

  # # ..................................................................... ###

  # Omega: sample columns before the expensive as.matrix() conversion so that
  # only the selected species-pair columns are held in memory.
  if (posterior_type == "omega") {

    ecokit::check_packages("coda")

    n_cols <- dim(coda_object[[1L]])[2L]

    if (n_omega > n_cols) {
      warning(
        "`n_omega` (", n_omega, ") exceeds the number of available species ",
        "combinations (", n_cols, "). Adjusting `n_omega` to use all ",
        "available combinations.", call. = FALSE, immediate. = TRUE)
      n_omega <- n_cols
    }

    # Random sample of column indices (without replacement); order not
    # guaranteed, so sort is not applied here — the final arrange() handles it.
    comb_sample <- sample.int(n = n_cols, size = n_omega)

    coda_data <- purrr::map(.x = coda_object, .f = ~ .x[, comb_sample]) %>%
      coda::as.mcmc.list() %>%
      as.matrix(iter = TRUE, chain = TRUE) %>%
      tibble::as_tibble() %>%
      dplyr::rename(chain = CHAIN, iter = ITER) %>%
      dplyr::mutate(chain = factor(chain), iter = as.integer(iter)) %>%
      dplyr::arrange(chain, iter) %>%
      tidyr::pivot_longer(
        cols = -c(chain, iter),
        names_to = "species_combs",
        values_to = "value")

  } else {

    # For rho/alpha/beta: convert the full coda object to a wide matrix,
    # then rename the CHAIN/ITER bookkeeping columns to lowercase.
    coda_data <- as.matrix(coda_object, iter = TRUE, chain = TRUE) %>%
      tibble::as_tibble() %>%
      dplyr::rename(chain = CHAIN, iter = ITER) %>%
      dplyr::mutate(chain = factor(chain), iter = as.integer(iter)) %>%
      dplyr::arrange(chain, iter)
  }

  # # ..................................................................... ###

  # Rho ----

  # Rho is a scalar phylogenetic signal parameter. coda exports it as a
  # single column named "var1"; rename it to "value" for consistency.

  if (posterior_type == "rho") {
    coda_data <- dplyr::rename(
      coda_data, dplyr::any_of(c(value = "var1", rho_1 = "rho[1]")))
  }

  # # ..................................................................... ###

  # Alpha ----

  # Alpha is indexed as Alpha<N>[<alpha_num>, <factor>]. Pivot to long format
  # then parse the compound column name into two separate factor columns
  # (alpha_num and factor) using a split-on-bracket approach.

  if (posterior_type == "alpha") {

    # Pivot all non-bookkeeping columns to long; "Alpha" column holds the raw
    # coda dimname string (e.g. "Alpha1[1, factor1]").
    coda_data <- tidyr::pivot_longer(
      data = coda_data, cols = -c(chain, iter),
      names_to = "Alpha", values_to = "value")

    # Parse unique Alpha dimnames once, then join back to avoid repeated
    # string operations on the full (potentially large) long tibble.
    coda_data <- dplyr::distinct(coda_data, Alpha) %>%
      dplyr::mutate(
        Alpha2 = purrr::map(
          .x = Alpha,
          .f = ~ {
            # Split on "[", remove the trailing "]", yielding
            # c("<alpha_num>", "<factor>") as character strings.
            stringr::str_split(.x, "\\[", simplify = TRUE) %>%
              as.character() %>%
              stringr::str_remove("\\]")
          })) %>%
      tidyr::unnest_wider("Alpha2", names_sep = "_") %>%
      purrr::set_names(c("Alpha", "alpha_num", "factor")) %>%
      dplyr::right_join(coda_data, by = "Alpha") %>%
      dplyr::mutate(
        Alpha = factor(Alpha),
        alpha_num = factor(alpha_num),
        factor = factor(factor)) %>%
      dplyr::select(
        Alpha, alpha_num, factor, chain, iter, value,
        dplyr::everything()) %>%
      dplyr::arrange(Alpha, chain, iter)
  }

  # # ..................................................................... ###

  # Beta ----

  # Beta dimnames follow the Hmsc convention B[<covariate>, <species_id>].
  # Polynomial terms generated by stats::poly(., degree = 2, raw = TRUE) are
  # encoded as "B[covariate_1, sp_X]" (linear) and "B[covariate_2, sp_X]"
  # (quadratic); they are renamed here to "_l" and "_q" for readability.

  if (posterior_type == "beta") {

    coda_data <- tidyr::pivot_longer(
      data = coda_data, cols = -c(chain, iter),
      names_to = "var_sp", values_to = "value")

    # Parse unique var_sp labels once, then join back.
    var_species <- dplyr::distinct(coda_data, var_sp) %>%
      dplyr::mutate(
        species = purrr::map(
          .x = var_sp,
          .f = ~ {
            .x %>%
              # Strip the B[...] wrapper and stats::poly() boilerplate.
              stringr::str_remove_all(
                "B\\[|B\\[|\\(|\\)|\\]|stats::poly") %>%
              stringr::str_replace_all(
                ", degree = 2, raw = TRUE", "_") %>%
              stringr::str_split(",", simplify = TRUE) %>%
              as.data.frame() %>%
              tibble::as_tibble() %>%
              stats::setNames(c("variable", "sp_id")) %>%
              dplyr::mutate_all(stringr::str_trim) %>%
              dplyr::mutate(
                variable = purrr::map_chr(
                  .x = variable,
                  .f = function(v) {
                    # Rename polynomial suffix _1 -> _l (linear),
                    # _2 -> _q (quadratic).
                    v %>%
                      stringr::str_replace_all("_1$", "_l") %>%
                      stringr::str_replace_all("_2$", "_q")
                  }))
          })) %>%
      tidyr::unnest_wider("species")

    coda_data <- var_species %>%
      dplyr::right_join(coda_data, by = "var_sp") %>%
      tidyr::nest(data = -c(variable, sp_id, var_sp)) %>%
      dplyr::arrange(variable, sp_id)
  }

  # # ..................................................................... ###

  # Omega ----

  # Omega dimnames follow Hmsc's Omega1[<sp_id1>, <sp_id2>] convention.
  # Parse the species pair from each combination label and nest by pair.

  if (posterior_type == "omega") {

    coda_data <- tibble::tibble(
      species_combs = unique(coda_data$species_combs)) %>%
      dplyr::mutate(
        sp_names = purrr::map(
          .x = species_combs,
          .f = ~ {
            # Remove "Omega1[" and "]", then split on comma or space to
            # extract the two species IDs. str_subset keeps only tokens
            # starting with "sp_" (the Hmsc species-label convention).
            stringr::str_remove_all(.x, "Omega1\\[|\\]") %>%
              stringr::str_split(",| ", simplify = TRUE) %>%
              as.character() %>%
              stringr::str_subset("^sp_") %>%
              purrr::set_names(c("sp1", "sp2"))
          })) %>%
      tidyr::unnest_wider("sp_names") %>%
      dplyr::right_join(coda_data, by = "species_combs") %>%
      tidyr::nest(data = -c(species_combs, sp1, sp2)) %>%
      dplyr::arrange(species_combs)
  }

  return(coda_data)
}
