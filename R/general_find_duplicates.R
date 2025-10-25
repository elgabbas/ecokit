#' Find duplicated files and directories within a given path
#'
#' This function scans a directory tree for duplicated files (by content hash)
#' and optionally duplicated directories (by identical file sets). It supports
#' filtering by file extension, minimum file size, and parallel processing.
#'
#' @param path Character. Root directory to scan for duplicates.
#' @param size_threshold Numeric. Minimum file size (in MB) to report as
#'   duplicate.
#' @param extensions Character vector. Optional file extensions (without the
#'   leading dot) to filter (case-insensitive); e.g., `c("csv", "txt")`). If
#'   provided, only files with these extensions are considered. . Directories
#'   are excluded if they don't match. Defaults to `NULL` (all files are
#'   considered).
#' @param n_cores Integer. Number of parallel workers to use (default: 1).
#' @param verbose Logical. Whether to print results to the console
#'   (default: `TRUE`).
#'
#' @return A list of tibbles with duplicated files and directories, if found.
#'   The `duplicated_files` tibble  (if any) contains the following columns:
#'   - `path`: root path scanned;
#'   - `dup_group`: duplicate group ID;
#'   - `files`: list-column of tibbles with absolute/relative paths and
#'   modification times;
#'   - `file_ext`: file extension(s) of the group;
#'   - `n_files`: number of duplicated files in the group;
#'   - `file_size_mb`: size (MB) of the first file in the group; and
#'   - `content_hash`: MD5 hash of the file content.
#'   The `duplicated_dirs` tibble (if any) contains the following columns:
#'   - `dir`: directory path at the duplicated level;
#'   - `dir_abs`: absolute path to the directory;
#'   - `n_files`: number of files in the directory;
#'   - `n_dup_dirs`: number of duplicated directories in the group;
#'   - `dup_group`: unique identifier for each group of duplicated directories.
#'
#' @export
#' @author Ahmed El-Gabbas
#'
#' @examples
#'
#' ecokit::load_packages(fs)
#'
#' # ----------------------------------------------------
#' # Example 1: Detect duplicate files with identical content
#' # ----------------------------------------------------
#'
#' temp_dir1 <- fs::path_temp("example1")
#' fs::dir_create(temp_dir1)
#'
#' # Create files with identical content
#' file1 <- fs::path(temp_dir1, "file1.txt")
#' file2 <- fs::path(temp_dir1, "file2.txt")
#' file3 <- fs::path(temp_dir1, "subdir", "file3.txt")
#' fs::dir_create(path(temp_dir1, "subdir"))
#' writeLines("This is some test content.", file1)
#' fs::file_copy(file1, file2, overwrite = TRUE)
#' fs::file_copy(file1, file3, overwrite = TRUE)
#'
#' # Create a unique file
#' unique_file <- fs::path(temp_dir1, "unique.txt")
#' writeLines("Different content.", unique_file)
#'
#' # Find duplicates
#' dups <- find_duplicates(temp_dir1, size_threshold = 0)
#'
#' dups$duplicated_files$files
#'
#' # Clean up
#' fs::dir_delete(temp_dir1)
#'
#' # # ||||||||||||||||||||||||||||||||||||||||||||||||||||| #
#'
#' # ----------------------------------------------------
#' # Example 2: Detect duplicate directories with identical file sets
#' # ----------------------------------------------------
#'
#' temp_dir2 <- fs::path_temp("example2")
#' fs::dir_create(temp_dir2)
#'
#' # Create duplicate directories
#' dir_a <- fs::path(temp_dir2, "dir_a")
#' dir_b <- fs::path(temp_dir2, "dir_b")
#' dir_c <- fs::path(temp_dir2, "dir_c")
#' fs::dir_create(dir_a)
#' fs::dir_create(dir_b)
#' fs::dir_create(dir_c)
#'
#' # Files in dir_a and dir_b (identical)
#' writeLines("Content 1", fs::path(dir_a, "file1.txt"))
#' writeLines("Content 2", fs::path(dir_a, "file2.txt"))
#' fs::file_copy(path(dir_a, "file1.txt"), fs::path(dir_b, "file1.txt"))
#' fs::file_copy(path(dir_a, "file2.txt"), fs::path(dir_b, "file2.txt"))
#'
#' # Different files in dir_c
#' writeLines("Content 3", path(dir_c, "file3.txt"))
#'
#' # Run the function (no extensions filter to include dirs)
#' dups <- find_duplicates(temp_dir2, size_threshold = 0)
#'
#' dups$duplicated_dirs
#'
#' dups$duplicated_files$files
#'
#' # Clean up
#' fs::dir_delete(temp_dir2)
#'
#' # # ||||||||||||||||||||||||||||||||||||||||||||||||||||| #
#'
#' # ----------------------------------------------------
#' # Example 3: Filter by extensions and size threshold
#' # ----------------------------------------------------
#'
#' temp_dir3 <- fs::path_temp("example3")
#' fs::dir_create(temp_dir3)
#'
#' # Create duplicate CSV files
#' csv1 <- fs::path(temp_dir3, "data1.csv")
#' csv2 <- fs::path(temp_dir3, "data2.csv")
#' writeLines("col1,col2\n1,2", csv1)
#' fs::file_copy(csv1, csv2)
#'
#' # Create small duplicate TXT file (below threshold)
#' txt1 <- fs::path(temp_dir3, "small1.txt")
#' txt2 <- fs::path(temp_dir3, "small2.txt")
#' writeLines("Small", txt1)
#' fs::file_copy(txt1, txt2)
#'
#' # Run with extensions filter and size threshold
#' dups <- find_duplicates(
#'   temp_dir3, extensions = "csv", size_threshold = 0.001)
#'
#' dups
#'
#' # Clean up
#' fs::dir_delete(temp_dir3)
#'
#' # # ||||||||||||||||||||||||||||||||||||||||||||||||||||| #
#'
#' # ----------------------------------------------------
#' # Example 4: Parallel processing with multiple cores
#' # ----------------------------------------------------
#'
#' temp_dir4 <- fs::path_temp("example4")
#' fs::dir_create(temp_dir3)
#'
#' # Create many duplicate files to test parallel
#' for (i in 1:5) {
#'   fs::dir_create(path(temp_dir4, paste0("group", i)))
#'   for (j in 1:3) {
#'     file_path <- fs::path(
#'       temp_dir4, paste0("group", i), paste0("dup", j, ".txt"))
#'     writeLines(paste("Content for group", i), file_path)
#'   }
#' }
#'
#' # Run with 2 cores
#' find_duplicates(temp_dir4, n_cores = 2, size_threshold = 0)
#'
#' # Clean up
#' dir_delete(temp_dir4)


find_duplicates <- function(
    path = ".", size_threshold = 0L, extensions = NULL, n_cores = 1L,
    verbose = TRUE) {

  if (is.null(path) || !is.character(path) || length(path) != 1L ||
      !nzchar(path)) {
    ecokit::stop_ctx(
      "The 'path' parameter must be a non-empty character string")
  }
  if (!fs::is_dir(path)) {
    ecokit::stop_ctx(
      "The specified 'path' does not exist or is not a directory",
      path = path)
  }

  is_dir <- dir_parts <- full_path <- file_size_mb <- content_hash <-
    files <- n_files <- NULL

  # Gather all files and directories under path
  file_list <- fs::dir_ls(path, recurse = TRUE, type = "any")

  # Optionally filter files by extensions (directories are excluded if they
  # don't match)
  valid_ext <- !is.null(extensions) &&
    length(extensions) > 0L && all(nzchar(extensions))
  if (valid_ext) {
    regex_ext <- stringr::str_c(
      "(?i)\\.(", stringr::str_c(extensions, collapse = "|"), ")$")
    file_list <- stringr::str_subset(file_list, regex_ext)
  }

  if (length(file_list) == 0L) {
    return(invisible(NULL))
  }

  if (n_cores == 1L) {
    future::plan("sequential")
  } else {
    future::plan("multisession", workers = n_cores)
    on.exit(future::plan("sequential"), add = TRUE)
  }

  # Pad directory parts to uniform depth and create cumulative directory paths
  # for leveled analysis
  file_list <- future.apply::future_lapply(
    X = file_list,
    FUN = function(file_path) {
      rel_path <- fs::path_rel(file_path, start = path)
      split_paths <- fs::path_split(rel_path)
      is_dir <- fs::is_dir(file_path)
      content_hash <- ifelse(
        is_dir, NA_character_, unname(tools::md5sum(file_path)))
      # Get directory parts (exclude file name for files)
      dir_parts <- purrr::map2(
        .x = split_paths, .y = is_dir,
        .f = ~ if (.y) .x else head(.x, -1L))
      # Get file name for files, NA for directories
      file_name <- purrr::map2_chr(
        .x = split_paths, .y = is_dir,
        .f = ~ if (.y) NA_character_ else tail(.x, 1L))
      tibble::tibble(
        full_path = file_path, rel_path = rel_path,
        is_dir = is_dir, content_hash = content_hash,
        file_name = file_name, dir_parts = dir_parts)
    },
    future.globals = "path",
    future.packages = c("tools", "tibble", "fs", "purrr", "stringr")) %>%
    dplyr::bind_rows()

  max_depth <- max(lengths(file_list$dir_parts)) # nolint

  file_list <- file_list %>%
    dplyr::mutate(
      # Pad directory parts to max_depth, then create cumulative paths
      dir_cum = purrr::map(
        .x = dir_parts,
        .f = ~ {
          # Pad parts to max_depth
          parts <- purrr::map_chr(
            .x = seq_len(max_depth),
            .f = function(idx) {
              if (idx <= length(.x)) .x[[idx]] else NA_character_
            })
          purrr::map_chr(seq_len(max_depth), function(i) {
            if (is.na(parts[i])) return(NA_character_)
            cum_parts <- parts[seq_len(i)]
            cum_parts <- cum_parts[!is.na(cum_parts)]
            if (length(cum_parts) == 0L) return(NA_character_)
            stringr::str_c(cum_parts, collapse = "/")
          })
        })) %>%
    tidyr::unnest_wider(tidyselect::all_of("dir_cum"), names_sep = "_") %>%
    dplyr::rename_with(
      ~ stringr::str_c("dir_l", seq_along(.)),
      tidyselect::matches("^dir_cum_"))

  # Arrange rows by directory columns and file_name
  level_cols <- stringr::str_subset(names(file_list), "^dir_l\\d+$") # nolint

  # Find duplicated directories using helper function
  if (length(level_cols) > 0L && isFALSE(valid_ext)) {
    duplicated_dirs <- file_list %>%
      dplyr::filter(is_dir) %>%
      find_duplicated_dirs() %>%
      dplyr::mutate(
        dir = fs::path(dir), dir_abs = fs::path(path, dir), .before = 2L)
    if (nrow(duplicated_dirs) > 0L) {
      if (verbose) {
        ecokit::info_chunk(
          "  >>  Duplicated directories", cat_date = FALSE,
          cat_bold = TRUE, line_char_rep = 32L)
        print(duplicated_dirs, n = Inf)
      }
    } else {
      duplicated_dirs <- NULL
    }
  }

  # Find duplicated files by content_hash
  dup_files <- file_list %>%
    # Only keep files (not directories)
    dplyr::filter(!is_dir) %>%
    dplyr::select(-is_dir) %>%
    dplyr::summarise(files = list(full_path), .by = content_hash) %>%
    dplyr::mutate(n_files = lengths(files)) %>%
    dplyr::filter(n_files > 1L)

  if (nrow(dup_files) == 0L) {
    return(invisible(NULL))
  }

  # Filter for files above size threshold
  dup_files <- dplyr::mutate(
    dup_files,
    file_size_mb = purrr::map_dbl(
      .x = files, .f = ~ round(fs::file_size(.x[1L]) / (1024L * 1024L), 2L)),
    file_ext = purrr::map_chr(
      .x = files, .f = ~ toString(unique(tools::file_ext(.x))))) %>%
    dplyr::filter(file_size_mb >= size_threshold)

  if (nrow(dup_files) == 0L) {
    return(invisible(NULL))
  }

  # Prepare duplicated files output
  selected_columns <- c(
    "dup_group", "files", "file_ext", "n_files", "file_size_mb", "content_hash")
  dup_files <- dup_files %>%
    dplyr::arrange(dplyr::desc(file_size_mb)) %>%
    dplyr::mutate(
      dup_group = dplyr::row_number(),
      files = purrr::map(
        .x = files,
        .f = ~ {
          files0 <- sort(.x)
          tibble::tibble(
            file_abs = files0, file_rel = fs::path_rel(file_abs, start = path),
            modified = fs::file_info(files0)$modification_time)
        })) %>%
    dplyr::select(tidyselect::all_of(selected_columns)) %>%
    dplyr::mutate(path = fs::path(path), .before = 1L)

  if (verbose) {
    ecokit::info_chunk(
      "  >>  Duplicated files", cat_date = FALSE,
      cat_bold = TRUE, line_char_rep = 32L)
    print(dup_files, n = 50L)
  }

  # Return duplicated files tibble (invisible)
  if (is.null(duplicated_dirs)) {
    output <- list(duplicated_files = dup_files)
  } else {
    output <- list(
      duplicated_dirs = duplicated_dirs,
      duplicated_files = dup_files)
  }

  invisible(output)

}

#' Find duplicated directories based on file content hashes.
#'
#' This internal function identifies directories within a file metadata table
#' that contain identical sets of files (based on SHA hashes), excluding parent
#' directories where all files reside in a single child subdirectory. It works
#' across multiple directory levels and returns a tibble of duplicated
#' directories, grouped by file count and SHA string.
#'
#' @param tbl A tibble containing file metadata, including columns for directory
#'   levels (e.g., `dir_l1`, `dir_l2`, ...), file SHA hashes (`content_hash`),
#'   and relative file paths (`rel_path`).
#'
#' @return A tibble with duplicated directories, including `dir`: directory path
#'   at the duplicated level; `n_files`: number of files in the directory;
#'   `dup_group`: unique identifier for each group of duplicated directories.
#'
#' @noRd
#' @keywords internal
#' @author Ahmed El-Gabbas

find_duplicated_dirs <- function(tbl) {

  dup_group <- n_dup_dirs <- n_files <- sha_string <- content_hashes <-
    first_part <- only_one_child <- direct_file <- n_unique_first <-
    after_dir <- file_rel_paths <- rel_path <- content_hash <- dir_cols <- NULL

  # Identify directory level columns (e.g. dir_l1, dir_l2, ...)
  dir_cols <- names(tbl)[stringr::str_detect(names(tbl), "^dir_l\\d+$")] # nolint

  # For each directory level, group by cumulative path, collect file hashes and
  # paths, and exclude wrappers around single child subdirectories
  selected_columns <- c(
    "file_rel_paths", "after_dir", "first_part", "direct_file",
    "n_unique_first", "only_one_child")
  duplicated_list <- purrr::map(
    .x = seq_along(dir_cols),
    .f = function(i) {
      col <- dir_cols[i]
      # Group files by directory at this level
      tbl %>%
        dplyr::filter(!is.na(.data[[col]])) %>%
        dplyr::group_by(dir = .data[[col]], .drop = TRUE) %>%
        dplyr::summarise(
          level = i, n_files = dplyr::n(),
          content_hashes = list(sort(content_hash)),
          file_rel_paths = list(rel_path),
          .groups = "drop") %>%
        # Exclude parent dirs with all files in a single child subdir
        dplyr::rowwise() %>%
        dplyr::mutate(
          # Remove parent dir prefix from each file path using stringr
          after_dir = stringr::str_remove(
            file_rel_paths, stringr::str_c("^", stringr::fixed(dir), "/")),
          # Get first path segment after parent dir (subdir or filename)
          first_part = purrr::map_chr(
            .x = stringr::str_split(after_dir, "/"), .f = ~ .x[1L]),
          # Check if any file is directly inside dir (not nested)
          direct_file = any(after_dir == first_part & nzchar(after_dir)),
          # Count number of unique first parts (subdirs)
          n_unique_first = length(unique(first_part[nzchar(first_part)])),
          # Exclude if all files are in one subdir and none are direct
          only_one_child = (
            !direct_file && n_unique_first == 1L && n_files > 0L)) %>%
        dplyr::filter(!only_one_child) %>%
        dplyr::ungroup() %>%
        # Remove intermediate columns to keep output clean
        dplyr::select(-tidyselect::all_of(selected_columns))
    })

  # Combine results from all levels into one tibble
  excluded_columns <- c("content_hashes", "sha_string", "level")
  duplicated_tbl <- duplicated_list %>%
    dplyr::bind_rows() %>%
    # Collapse content_hash vector into a single string for group identification
    dplyr::mutate(
      sha_string = purrr::map_chr(
        .x = content_hashes, .f = stringr::str_c, collapse = "|")) %>%
    # Group by file count and content_hash string to find duplicates
    dplyr::group_by(n_files, sha_string) %>%
    dplyr::mutate(n_dup_dirs = dplyr::n()) %>%
    # Only keep groups with more than one duplicated directory
    dplyr::filter(n_dup_dirs > 1L) %>%
    # Assign a unique duplicate group ID
    dplyr::mutate(dup_group = dplyr::cur_group_id()) %>%
    dplyr::ungroup() %>%
    # Drop internal columns for clean output
    dplyr::select(-tidyselect::all_of(excluded_columns)) %>%
    # Sort by file count, group, path
    dplyr::arrange(dplyr::desc(n_files), dup_group, dir)

  # Return the tibble of duplicated directories
  duplicated_tbl
}
