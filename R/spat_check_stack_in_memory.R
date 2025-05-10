## |------------------------------------------------------------------------| #
# check_stack_in_memory ------
## |------------------------------------------------------------------------| #

#' Check if a raster stack reads from disk or memory
#'
#' This function checks whether the layers of a RasterStack object are stored in
#' memory or read from disk.  It prints messages indicating whether all layers
#' are in memory, all layers are on disk, or a mix of both. If there's a mix, it
#' specifies which layers are on disk.
#' @author Ahmed El-Gabbas
#' @export
#' @name check_stack_in_memory
#' @param stack A RasterStack object. If `NULL`, empty, or not a `RasterStack`,
#'   the function stops with an error or prints a message for empty stacks.
#' @return Returns `invisible(NULL)` and prints messages to the console
#'   indicating whether all layers are in memory, all are read from disk, or a
#'   mix (specifying which layers are read from disk).
#' @examples
#' load_packages(raster)
#'
#' # create a small in-memory raster
#' r_1 <- raster::raster(nrows = 10, ncols = 10, vals = 1)
#' r_2 <- raster::raster(nrows = 10, ncols = 10, vals = 2)
#'
#' # create a stack with one disk-based and one in-memory layer
#' temp_file_1 <- tempfile(fileext = ".tif")
#' raster::writeRaster(r_1, temp_file_1)
#' temp_file_2 <- tempfile(fileext = ".tif")
#' raster::writeRaster(r_2, temp_file_2)
#'
#' # ---------------------------------------------
#'
#' stack1 <- raster::stack(temp_file_1, r_1)
#' check_stack_in_memory(stack1)
#'
#' # ---------------------------------------------
#'
#' stack3 <- raster::stack(temp_file_1, temp_file_2)
#' check_stack_in_memory(stack3)
#'
#' # ---------------------------------------------
#'
#' stack2 <- raster::stack(r_1, r_2)
#' check_stack_in_memory(stack2)
#'
#' # ---------------------------------------------
#'
#' # clean up
#' fs::file_delete(c(temp_file_1, temp_file_2))

check_stack_in_memory <- function(stack = NULL) {

  # Check input argument
  if (is.null(stack)) {
    ecokit::stop_ctx("Input stack cannot be NULL", stack = stack)
  }

  if (!inherits(stack, "RasterStack")) {
    ecokit::stop_ctx(
      "The object should be a RasterStack object",
      stack = stack, class_stack = class(stack))
  }

  # Check for empty stack
  if (raster::nlayers(stack) == 0L) {
    message("The stack is empty (no layers)")
  }

  in_memory <- purrr::map_lgl(raster::unstack(stack), raster::inMemory)

  if (all(in_memory)) {
    message("All stack layers reads from ", crayon::bold("memory"))
  } else if (any(in_memory)) {
    disk_layers <- which(!in_memory)
    message(
      "Mixed storage: layers ", toString(disk_layers),
      " are read from ", crayon::bold("disk"),
      "; others are in ", crayon::bold("memory"))
  } else {
    message("All stack layers are read from ", crayon::bold("disk"))
  }
  return(invisible(NULL))
}
