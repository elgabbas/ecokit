## |------------------------------------------------------------------------| #
# git_log ----
## |------------------------------------------------------------------------| #

#' Print or return a detailed `git log` of the git repository located in the
#' specified directory.
#'
#' This function checks if the specified directory is a Git repository and, if
#' so, executes a `git log` command to either print the log to the console or
#' return it. It supports execution on Windows and Linux operating systems and
#' provides a visually appealing graph format of the log, showing the commit
#' hash, references, commit message, relative commit date, and author name.
#' @param path Character. Path to the directory to check. Defaults to the
#'   current working directory ".". If the path does not exist, the function
#'   will stop and throw an error. If the path is not a git repository, the
#'   function will throw a warning.
#' @param n_commits Integer. Number of recent commits to display. If `NULL` (the
#'   default), the complete log is shown. If `n_commits` is not `NULL` or a
#'   positive number, the function will stop and throw an error. This parameter
#'   is ignored if `return_log` is `TRUE`.
#' @param return_log Logical. Whether to return the log (`TRUE`) or print it to
#'   the console (`FALSE`, default). If `TRUE`, the function returns a character
#'   vector containing the log lines.
#' @return If `return_log` is `TRUE`, returns a character vector containing the
#'   git log lines. If `return_log` is `FALSE`, the function is called for its
#'   side effect of printing to the console.
#' @note The function will stop and throw an error if the specified path does
#'   not exist, the operating system is not supported, the directory is not a
#'   Git repository, Git is not installed, or if the `n_commits` parameter is
#'   not `NULL` or a positive number.
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
#' # Return the log as a character vector
#' Log <- git_log(return_log = TRUE)
#'
#' length(Log)
#'
#' head(Log, 8)
#'
#' \dontrun{
#'   # not a git repo
#'   git_log(path = "C:/")
#'   # #> Error: The provided path does not exist.
#' }

git_log <- function(path = ".", n_commits = NULL, return_log = FALSE) {

  # Check `git` system command
  if (isFALSE(ecokit::check_system_command("git"))) {
    ecokit::stop_ctx("The system command 'git' is not available")
  }

  if (!dir.exists(path)) {
    ecokit::stop_ctx("The provided path does not exist.", path = path)
  }

  # Determine the OS-specific command
  os <- ecokit::OS()

  if (!os %in% c("Windows", "Linux")) {
    ecokit::stop_ctx(
      "Unsupported OS. This function supports only Windows and Linux.",
      os = os)
  }

  # Construct the command to check if the directory is a Git repo
  git_check_command <- if (os == "Windows") {
    paste0(
      'cmd.exe /c "cd /d ', ecokit::normalize_path(path),
      ' && git rev-parse --is-inside-work-tree"')
  } else {
    paste0(
      'sh -c "cd ', ecokit::normalize_path(path),
      ' && git rev-parse --is-inside-work-tree"')
  }

  # Check if the directory is a Git repo
  is_git <- tryCatch({
    result <- system(
      command = git_check_command, intern = TRUE, ignore.stderr = TRUE) %>%
      suppressWarnings()

    if (length(result) == 0) {
      message("The git_check_command returned an empty result.")
      return(invisible(NULL))
    }
    result
  },
  error = function(e) {
    message("Error checking if directory is a Git repository: ", e$message)
    return(invisible(NULL))
  })

  if (is.null(is_git)) {
    ecokit::stop_ctx(
      "Failed to determine if the directory is a Git repository.",
      is_git = is_git)
  }

  if (is_git == "true") {
    # Construct the command to get the Git log
    log_command <- paste0(
      "git -C ", ecokit::normalize_path(path),
      ' log --graph --pretty=format:"%Cred%h%Creset ',
      "-%C(yellow)%d%Creset %s %Cgreen(%cr) ",
      '%C(bold blue)<%an>%Creset" --abbrev-commit')

    # Execute the command and capture the output
    log_output <- tryCatch({
      ecokit::system_command(log_command, R_object = TRUE)
    },
    error = function(e) {
      ecokit::stop_ctx(
        paste0(
          "Failed to retrieve Git log. Ensure Git is installed and the ",
          "directory is a valid Git repository."))
    })

    if (isFALSE(return_log)) {
      # Print the log output
      if (is.null(n_commits)) {
        cat(log_output, sep = "\n")
      } else {

        if (!(is.numeric(n_commits) && n_commits > 0)) {
          ecokit::stop_ctx(
            paste0(
              "The 'n_commits' argument can be either NULL to show the ",
              "complete log or a positive numeric value to show the ",
              "most recent commits."),
            n_commits = n_commits)
        }
        cat(utils::head(log_output, n = n_commits), sep = "\n")
      }
    }
  } else {
    warning("The provided directory is not a Git repository.", call. = FALSE)
  }

  if (return_log) {
    return(log_output)
  } else {
    return(invisible(NULL))
  }
}
