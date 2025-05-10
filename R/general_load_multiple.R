## |------------------------------------------------------------------------| #
# load_multiple ----
## |------------------------------------------------------------------------| #

#' Load multiple data files together
#'
#' This function loads multiple data files either into a single list object or
#' directly into the specified environment. It provides options for verbosity,
#' returning object names, and handling of non-existent files. Supported data
#' files include: `.RData`, `.rds`, `.qs2`, and `.feather`.
#' @param files Character vector. Paths to `.RData`, `.rds`, `.qs2`, or
#'   `.feather` files to be loaded.
#' @param verbose Logical. Whether to print progress messages. Default: `TRUE`.
#' @param single_object Logical. Whether to load all objects into a single list
#'   (`TRUE`) or directly into the specified environment (`FALSE`). Defaults to
#'   `TRUE`.
#' @param return_names Logical. Whether to return the names of the loaded
#'   objects. Defaults to `TRUE`. Only effective when `single_object` is
#'   `FALSE`.
#' @param n_threads Integer. Number of threads for reading `.qs2` files. Must be
#'   a positive integer. Default is 5.
#' @param conflict Character. Strategy for handling naming conflicts when
#'   `single_object = FALSE`: `"skip"` (default, skip conflicting files),
#'   `"overwrite"` (replace existing objects), or `"rename"` (append a suffix to
#'   new objects).
#' @param environment Environment. The environment where objects are loaded when
#'   `single_object` is `FALSE`. Defaults to `.GlobalEnv`.
#' @return If `single_object` is `TRUE`, returns a named list of objects loaded
#'   from the specified files (with `NULL` for failed loads). If `single_object`
#'   is `FALSE` and `return_names` is `TRUE`, returns a character vector of the
#'   names of the objects loaded into the environment. Otherwise, returns
#'   `NULL`.
#' @note For `.RData` files containing multiple objects, the function loads each
#'   object individually and applies the `conflict` strategy to each.
#'   Non-conflicting objects retain their original names in `rename` mode.
#' @author Ahmed El-Gabbas
#' @name load_multiple
#' @export
#' @examples
#' ecokit::load_packages(qs2, arrow, fs, terra, dplyr)
#'
#' # ---------------------------------------------------
#' # Create sample data files
#' # ---------------------------------------------------
#'
#' # Setup temporary directory
#' temp_dir <- fs::path_temp("load_multiple")
#' fs::dir_create(temp_dir)
#'
#' # Create sample data files
#' data1 <- terra::wrap(terra::rast(matrix(1:16, nrow = 4)))
#' data2 <- matrix(1:9, nrow = 3)
#' data3 <- list(a = 1:10, b = letters[1:5])
#' data4 <- data.frame(x = 1:5)
#'
#' save(data1, file = fs::path(temp_dir, "data1.RData"))
#' saveRDS(data2, file = fs::path(temp_dir, "data2.rds"))
#' qs2::qs_save(data3, file = fs::path(temp_dir, "data3.qs2"), nthreads = 1)
#' arrow::write_feather(
#'   as.data.frame(data4), sink = fs::path(temp_dir, "data4.feather"))
#'
#' files <- fs::path(
#'   temp_dir, c("data1.RData", "data2.rds", "data3.qs2", "data4.feather"))
#' basename(files)
#'
#' # Create a specific environment for examples
#' example_env <- new.env()
#'
#' # ---------------------------------------------------
#' # Load mixed data files to one list object
#' # `single_object = TRUE`
#' # ---------------------------------------------------
#'
#' MultiObj <- load_multiple(files = files, single_object = TRUE)
#' str(MultiObj, 1)
#'
#' # ---------------------------------------------------
#' # Load mixed data files separately to the specific environment
#' # `single_object = FALSE`, skip conflicts
#' # ---------------------------------------------------
#'
#' # Remove any existing objects in example_env
#' rm(list = ls(envir = example_env), envir = example_env)
#'
#' # Create conflicting object in example_env
#' assign("data2", "conflict", envir = example_env)
#' load_multiple(
#'   files = files, single_object = FALSE, conflict = "skip",
#'   environment = example_env)
#' ls(envir = example_env)
#'
#' str(get("data1", envir = example_env), 1)
#' str(get("data2", envir = example_env), 1)
#' str(get("data3", envir = example_env), 1)
#' str(get("data4", envir = example_env), 1)
#'
#' # ---------------------------------------------------
#' # Load mixed data files, overwrite conflicts
#' # `single_object = FALSE`, overwrite
#' # ---------------------------------------------------
#'
#' # Remove specific objects from example_env
#' rm(list = c("data1", "data3", "data4"), envir = example_env)
#' ls(envir = example_env)
#'
#' load_multiple(
#'   files = files, single_object = FALSE, conflict = "overwrite",
#'   environment = example_env)
#' ls(envir = example_env)
#'
#' str(get("data1", envir = example_env), 1)
#' str(get("data2", envir = example_env), 1)
#' str(get("data3", envir = example_env), 1)
#' str(get("data4", envir = example_env), 1)
#'
#' # ---------------------------------------------------
#' # Load mixed data files, rename conflicts
#' # `single_object = FALSE`, rename
#' # ---------------------------------------------------
#'
#' # Remove specific objects from example_env
#' rm(list = c("data1", "data3", "data4"), envir = example_env)
#' ls(envir = example_env)
#'
#' # Create conflicting object in example_env
#' assign("data2", 1:10, envir = example_env)
#'
#' load_multiple(
#'   files = files, single_object = FALSE, conflict = "rename",
#'   environment = example_env)
#' ls(envir = example_env)
#'
#' str(get("data1", envir = example_env), 1)
#' str(get("data2", envir = example_env), 1)
#' str(get("data2_new", envir = example_env), 1)
#' str(get("data3", envir = example_env), 1)
#' str(get("data4", envir = example_env), 1)
#'
#' # Clean up
#' fs::file_delete(files)
#' fs::dir_delete(temp_dir)
#' rm(example_env)

load_multiple <- function(
    files = NULL, verbose = TRUE, single_object = TRUE, return_names = TRUE,
    n_threads = 5L, conflict = c("skip", "overwrite", "rename"),
    environment = .GlobalEnv) {

  # Validate inputs ----
  # Ensure files is not NULL or empty
  if (is.null(files) || length(files) == 0L) {
    ecokit::stop_ctx("`files` cannot be NULL or empty", files = files)
  }

  # Check if files is a character vector
  if (!is.character(files)) {
    ecokit::stop_ctx("`files` must be a character vector", files = files)
  }

  # Verify verbose is a single logical value
  if (!all(is.logical(verbose), length(verbose) == 1L, !is.na(verbose))) {
    ecokit::stop_ctx(
      "`verbose` must be a single logical value", verbose = verbose)
  }

  # Ensure n_threads is a positive integer
  if (!is.numeric(n_threads) || n_threads < 1L ||
      n_threads != as.integer(n_threads)) {
    ecokit::stop_ctx(
      "`n_threads` must be a positive integer", n_threads = n_threads)
  }

  # Match conflict argument to valid options
  conflict <- match.arg(conflict)

  # Check if single_object is a single logical value
  if (!all(
    is.logical(single_object), length(single_object) == 1L,
    !is.na(single_object))) {
    ecokit::stop_ctx(
      "`single_object` must be a single logical value",
      single_object = single_object)
  }

  # Verify return_names is a single logical value
  if (!all(
    is.logical(return_names), length(return_names) == 1L,
    !is.na(return_names))) {
    ecokit::stop_ctx(
      "`return_names` must be a single logical value",
      return_names = return_names)
  }

  # Ensure environment is a valid environment
  if (!is.environment(environment)) {
    ecokit::stop_ctx(
      "`environment` must be an environment", environment = environment)
  }

  # Check file existence and valid extensions
  if (!all(file.exists(files))) {
    ecokit::stop_ctx(
      "Some files do not exist. No objects were loaded!",
      files = files[!file.exists(files)])
  }

  extensions <- tolower(tools::file_ext(files))
  if (!all(extensions %in% c("rdata", "rds", "qs2", "feather"))) {
    ecokit::stop_ctx(
      "All files must be .rdata, .rds, .qs2, or .feather files",
      files = files[!extensions %in% c("rdata", "rds", "qs2", "feather")])
  }

  # Load files into a single list if single_object is TRUE
  if (single_object) {

    if (verbose) {
      cat(
        crayon::bold(
          crayon::blue("Loading all objects as a single R object\n")))
    }

    # Get base names for list elements
    list_names <- tools::file_path_sans_ext(basename(files))

    # Load each file into a named list
    output <- purrr::imap(
      .x = files,
      .f = function(file, idx) {
        # Attempt to load file using ecokit::load_as
        obj <- try(ecokit::load_as(file, n_threads = n_threads), silent = TRUE)

        # Handle load errors
        if (inherits(obj, "try-error")) {
          if (verbose) {
            message("Failed to load file: ", file)
          }
          return(NULL)
        }

        # Print success message if verbose
        if (verbose) {
          cat(
            crayon::blue(
              "Object: ", crayon::red(list_names[idx]),
              " was loaded successfully\n"))
        }
        obj
      }) %>%
      stats::setNames(list_names)

    # Stop if no valid objects were loaded
    if (all(purrr::map_lgl(output, is.null))) {
      ecokit::stop_ctx("No valid objects loaded from files", files = files)
    }

    return(output)

  } else {

    if (verbose) {
      cat(crayon::bold(crayon::blue("Loading all objects separately \n")))
    }

    # Initialize vector to track loaded object names
    objects_loaded <- character()

    # Process each file
    for (file in files) {
      # Create temporary environment for loading
      temp_env <- new.env()

      # Load file content
      obj <- try(ecokit::load_as(file, n_threads = n_threads), silent = TRUE)
      if (inherits(obj, "try-error")) {
        if (verbose) {
          message("Failed to load file: ", file)
        }
        next
      }

      # Determine object names and structure
      ext <- tolower(tools::file_ext(file))
      is_multi_object <- ext == "rdata" && is.list(obj) &&
        !is.data.frame(obj) && !is.null(names(obj))
      names <- if (is_multi_object) {
        names(obj)
      } else {
        tools::file_path_sans_ext(basename(file))
      }
      objects <- if (is_multi_object) {
        obj
      } else {
        list(obj)
      }

      # Handle naming conflicts
      existing <- ls(envir = environment)
      conflict_result <- switch(
        conflict,
        rename = {
          # Function to generate unique names for conflicting objects
          generate_unique_names <- function(name, existing_names) {
            if (!(name %in% existing_names)) return(name)
            suffix <- "_new"
            new_name <- paste0(name, suffix)
            while (new_name %in% existing_names) {
              suffix <- paste0(suffix, "_new")
              new_name <- paste0(name, suffix)
            }
            new_name
          }
          # Generate unique names iteratively
          reduce_result <- purrr::reduce(
            names,
            .f = function(acc, name) {
              new_name <- generate_unique_names(name, acc$existing)
              list(
                final_names = c(acc$final_names, new_name),
                existing = c(acc$existing, new_name))
            },
            .init = list(final_names = character(), existing = existing))
          list(
            final_names = reduce_result$final_names,
            names = names, objects = objects)
        },
        skip = {
          # Identify objects to load (non-conflicting)
          names_to_load <- names[!names %in% existing]
          messages <- character()
          if (verbose) {
            # Generate messages for all objects
            if (length(names_to_load) > 0L) {
              # Some objects loaded, some skipped
              messages <- purrr::map_chr(
                .x = names,
                .f = ~if (.x %in% names_to_load) {
                  crayon::blue(
                    sprintf(
                      "Object %s was loaded successfully from file %s\n",
                      crayon::red(.x), crayon::red(basename(file))))
                } else {
                  crayon::blue(sprintf(
                    "Object %s exists; skipped from file %s\n",
                    crayon::red(.x), crayon::red(basename(file))))
                })
            } else {
              # All objects skipped
              messages <- purrr::map_chr(
                names,
                ~crayon::blue(
                  sprintf(
                    "Object %s exists; skipped from file %s\n",
                    crayon::red(.x), crayon::red(basename(file)))))
            }
          }
          list(
            final_names = names_to_load, names = names_to_load,
            objects = objects[names %in% names_to_load], messages = messages)
        },
        overwrite = list(final_names = names, names = names, objects = objects))

      # Print skip messages and skip file if no objects to load
      if (conflict == "skip" && verbose &&
          length(conflict_result$messages) > 0L) {
        purrr::walk(conflict_result$messages, cat)
      }
      if (length(conflict_result$final_names) == 0L) {
        next
      }
      final_names <- conflict_result$final_names
      names <- conflict_result$names
      objects <- conflict_result$objects

      # Check existing objects before assignment
      existing_before <- ls(envir = environment)
      exists_before <- names %in% existing_before

      # Assign objects to temporary environment
      for (i in seq_along(names)) {
        assign(names[i], objects[[i]], envir = temp_env)
      }

      # Assign objects to target environment
      for (i in seq_along(names)) {
        assign(final_names[i], objects[[i]], envir = environment)
      }
      objects_loaded <- c(objects_loaded, final_names)

      # Print messages for rename and overwrite cases
      if (verbose && length(final_names) > 0L && conflict != "skip") {
        for (i in seq_along(names)) {
          if (conflict == "rename" && final_names[i] != names[i]) {
            cat(
              crayon::blue(
                "Object: ", crayon::red(names[i]), " exists; loaded as ",
                crayon::red(final_names[i]), "\n"))
          } else if (conflict == "overwrite" && exists_before[i]) {
            cat(
              crayon::blue(
                "Object: ", crayon::red(final_names[i]),
                " already exists and overwritten\n"))
          } else {
            cat(
              crayon::blue(
                "Object: ", crayon::red(final_names[i]),
                " was loaded successfully\n"))
          }
        }
      }
    }

    # Handle case where no objects were loaded
    if (length(objects_loaded) == 0L) {
      message("No objects loaded due to conflicts or invalid files")
      return(invisible(NULL))
    }

    # Return object names if requested
    if (return_names) {
      return(objects_loaded)
    } else {
      return(invisible(NULL))
    }
  }
}
