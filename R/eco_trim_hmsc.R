## |------------------------------------------------------------------------| #
# trim_hmsc ----
## |------------------------------------------------------------------------| #

#' Trim an `Hmsc` model object by removing specified components
#'
#' Removes named components from a fitted [`Hmsc::Hmsc`] model object, returning
#' a lighter object that retains only the elements needed for downstream
#' computations. This is particularly useful when a fitted model is large
#' (several GB) and copies must be shipped to parallel workers via SLURM array
#' jobs or `future`-based parallel backends, where transferring the full object
#' would be prohibitively slow or exceed memory limits.
#'
#' @param model An object of class `Hmsc`. Must not be `NULL`.
#' @param names_to_remove Character vector. Names of components to remove from
#'   `model` (e.g. `c("postList", "rL", "ranLevels")`). Duplicate names are
#'   silently dropped. All supplied names must exist in `model`; unrecognised
#'   names trigger an error. Cannot be `NULL` or empty.
#' @return An `Hmsc` object with the specified components removed. Returned
#'   invisibly.
#' @details The function converts the `Hmsc` object to a plain `list` before
#'   removing components, then restores the `"Hmsc"` class attribute. Conversion
#'   to a plain list avoids S3-dispatch overhead that would otherwise be
#'   triggered by modifying `Hmsc` slots directly.
#'
#'   Components are removed one at a time with a `for` loop rather than via
#'   vectorised subsetting (e.g. `model[names_to_remove] <- NULL`). Although the
#'   vectorised form is syntactically simpler, benchmarking on large models
#'   inside SLURM-submitted jobs showed the iterative approach to be
#'   substantially faster in practice, likely due to how R handles
#'   copy-on-modify semantics for large named lists.
#'
#'   A call to [base::gc()] is made before returning to prompt immediate release
#'   of the memory freed by removal.
#' @author Ahmed El-Gabbas
#' @export
#' @seealso [Hmsc::Hmsc()] for the full model object structure;
#'   [Hmsc::sampleMcmc()] for the fitting step that populates `postList`.
#' @examples
#' library(Hmsc)
#'
#' # Fitted example model bundled with Hmsc
#' (model <- Hmsc::TD$m)
#'
#' # Remove large posterior and random-level components
#' (trimmed_model <- trim_hmsc(
#'   model = model, names_to_remove = c("postList", "rL", "ranLevels")))
#'
#' # Components that were removed
#' setdiff(names(model), names(trimmed_model))
#'
#' # Memory savings
#' lobstr::obj_size(model)
#' lobstr::obj_size(trimmed_model)

trim_hmsc <- function(model, names_to_remove = NULL) {

  # Input validation ------

  if (is.null(model)) {
    ecokit::stop_ctx(
      "`model` cannot be `NULL`.", include_backtrace = TRUE)
  }

  if (!inherits(model, "Hmsc")) {
    ecokit::stop_ctx(
      "`model` must be an object of class `Hmsc`.",
      class_model = class(model), include_backtrace = TRUE)
  }

  if (is.null(names_to_remove) ||
      !is.character(names_to_remove) || length(names_to_remove) == 0L) {
    ecokit::stop_ctx(
      "`names_to_remove` must be a non-empty character vector.",
      names_to_remove = names_to_remove, include_backtrace = TRUE)
  }

  names_to_remove <- unique(names_to_remove)

  names_not_found <- setdiff(names_to_remove, names(model))
  if (length(names_not_found) > 0L) {
    ecokit::stop_ctx(
      paste0(
        "The following names in `names_to_remove` are not present in `model`:",
        "\n  ", toString(names_not_found)),
      names_not_found = names_not_found, include_backtrace = TRUE)
  }

  # ..................................................................... ###

  # Convert to plain list, remove components, restore class ------

  model <- as.list(model)

  for (name in names_to_remove) {
    model[[name]] <- NULL
  }

  class(model) <- "Hmsc"

  # ..................................................................... ###

  invisible(gc())
  return(model)
}
