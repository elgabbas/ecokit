## |------------------------------------------------------------------------| #
# git_log ----
## |------------------------------------------------------------------------| #

#' Print or return a detailed Git log of a repository
#'
#' Checks if the specified directory is a Git repository and, if so, executes a
#' `git log` command to either print the log to the console or return it as a
#' character vector. The log is displayed in a visually appealing graph format,
#' showing commit hashes, references, messages, relative dates, and authors.
#'
#' @param path Character. Path to the directory to check. Defaults to the
#'   current working directory `"."`. If the path does not exist, the function
#'   stops with an error. If the path is not a Git repository, a warning is
#'   issued.
#' @param n_commits Integer. Number of recent commits to display. If `NULL`
#'   (default), the complete log is shown. Ignored if `return_log = TRUE`.
#' @param return_log Logical. If `TRUE`, returns the log as a character vector.
#'   If `FALSE` (default), prints the log to the console.
#' @return If `return_log = TRUE`, returns a character vector of log lines. If
#'   `return_log = FALSE`, the function is called for its side effect of
#'   printing to the console and returns `invisible(NULL)`.
#' @note The function stops with an error if the path does not exist, the OS is
#'   unsupported, Git is not installed, or `n_commits` is invalid. Supports
#'   Windows and Linux only.
#' @name git_log
#' @author Ahmed El-Gabbas
#' @export
#' @examples
#' # Show the most recent commit
#' git_log(n_commits = 1)
#'
#' # Show the most recent 5 commits
#' git_log(n_commits = 5)
#'
#' # by default, the log is only printed, not returned
#' log_example <- git_log(n_commits = 1)
#' print(log_example)
#'
#' # Return the complete log as a character vector
#' log_example <- git_log(return_log = TRUE)
#' length(log_example)
#' head(log_example, 8)
#'
#' # not a git repo
#' non_git_dir <- fs::path(tempdir(), "test_dir")
#' fs::dir_create(non_git_dir)
#' git_log(path = non_git_dir)
#'
#' # clean up
#' unlink(non_git_dir, recursive = TRUE)

git_log <- function(path = ".", n_commits = NULL, return_log = FALSE) {

  # Check if Git is installed
  if (!ecokit::check_system_command("git")) {
    ecokit::stop_ctx("The system command 'git' is not available")
  }

  # Validate path
  if (!dir.exists(path)) {
    ecokit::stop_ctx("The provided path does not exist", path = path)
  }

  # Determine OS
  os <- ecokit::os()
  if (!os %in% c("Windows", "Linux")) {
    ecokit::stop_ctx(
      "Unsupported OS. Only Windows and Linux are supported", os = os)
  }

  # Construct command to check if directory is a Git repo
  git_check_command <- if (os == "Windows") {
    paste0(
      'cmd.exe /c "cd /d ', ecokit::normalize_path(path),
      ' && git rev-parse --is-inside-work-tree"')
  } else {
    paste0(
      'sh -c "cd ', ecokit::normalize_path(path),
      ' && git rev-parse --is-inside-work-tree"')
  }

  # Execute check command
  is_git <- tryCatch({
    output <- system(
      command = git_check_command, intern = TRUE, ignore.stderr = TRUE) %>%
      suppressWarnings()
    if (length(output) == 1L && output == "true") {
      "true"
    } else {
      NULL
    }
  },
  error = function(e) NULL)

  if (is.null(is_git)) {
    message(crayon::red(" ! The provided directory is not a Git repository"))
    return(invisible(NULL))
  }

  # Construct Git log command
  log_command <- paste0(
    "git -C ", ecokit::normalize_path(path),
    ' log --graph --pretty=format:"%Cred%h%Creset ',
    "-%C(yellow)%d%Creset %s %Cgreen(%cr) ",
    '%C(bold blue)<%an>%Creset" --abbrev-commit')

  # Execute log command
  log_output <- tryCatch(
    ecokit::system_command(log_command, r_object = TRUE),
    error = function(e) {
      message("Failed to retrieve Git log: ", e$message)
      NULL
    }
  )

  if (is.null(log_output)) {
    return(invisible(NULL))
  }

  # Handle output based on return_log and n_commits
  if (return_log) {
    return(log_output)
  } else {
    if (!is.null(n_commits)) {
      if (!is.numeric(n_commits) || n_commits <= 0L) {
        ecokit::stop_ctx(
          "`n_commits` must be a positive integer", n_commits = n_commits)
      }
      log_output <- utils::head(log_output, n = n_commits)
    }
    cat(log_output, sep = "\n")
    return(invisible(NULL))
  }

}
