# Print or return a detailed Git log of a repository

Checks if the specified directory is a Git repository and, if so,
executes a `git log` command to either print the log to the console or
return it as a character vector. The log is displayed in a visually
appealing graph format, showing commit hashes, references, messages,
relative dates, and authors.

## Usage

``` r
git_log(path = ".", n_commits = NULL, return_log = FALSE)
```

## Arguments

- path:

  Character. Path to the directory to check. Defaults to the current
  working directory `"."`. If the path does not exist, the function
  stops with an error. If the path is not a Git repository, a warning is
  issued.

- n_commits:

  Integer. Number of recent commits to display. If `NULL` (default), the
  complete log is shown. Ignored if `return_log = TRUE`.

- return_log:

  Logical. If `TRUE`, returns the log as a character vector. If `FALSE`
  (default), prints the log to the console.

## Value

If `return_log = TRUE`, returns a character vector of log lines. If
`return_log = FALSE`, the function is called for its side effect of
printing to the console and returns `invisible(NULL)`.

## Note

The function stops with an error if the path does not exist, the OS is
unsupported, Git is not installed, or `n_commits` is invalid.

## Author

Ahmed El-Gabbas

## Examples

``` r
# Show the most recent commit
git_log(n_commits = 1)
#> * c686df3 - (grafted, HEAD -> main, origin/main) Fix binned_heatmap (5 minutes ago) <Ahmed El-Gabbas>

# Show the most recent 5 commits
git_log(n_commits = 5)
#> * c686df3 - (grafted, HEAD -> main, origin/main) Fix binned_heatmap (5 minutes ago) <Ahmed El-Gabbas>

# by default, the log is only printed, not returned
log_example <- git_log(n_commits = 1)
#> * c686df3 - (grafted, HEAD -> main, origin/main) Fix binned_heatmap (5 minutes ago) <Ahmed El-Gabbas>
print(log_example)
#> NULL

# Return the complete log as a character vector
log_example <- git_log(return_log = TRUE)
length(log_example)
#> [1] 1
head(log_example, 8)
#> [1] "* c686df3 - (grafted, HEAD -> main, origin/main) Fix binned_heatmap (5 minutes ago) <Ahmed El-Gabbas>"

# not a git repo
non_git_dir <- fs::path_temp("test_dir")
fs::dir_create(non_git_dir)
git_log(path = non_git_dir)
#>  ! The provided directory is not a Git repository

# clean up
fs::dir_delete(non_git_dir)
```
