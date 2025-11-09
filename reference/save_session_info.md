# Save session information to a text file

Saves R session information, including platform details, package
versions, and optionally, a summary of objects in the session, to a text
file.

## Usage

``` r
save_session_info(out_directory = getwd(), session_info = NULL, prefix = "S")
```

## Arguments

- out_directory:

  Character. Directory path where the output file is saved. Defaults to
  the current working directory
  ([`base::getwd()`](https://rdrr.io/r/base/getwd.html)).

- session_info:

  An optional tibble or data frame with object details (e.g., from
  [`save_session()`](https://elgabbas.github.io/ecokit/reference/save_session.md)).
  If provided, details of objects (e.g., names and sizes in MB) are
  appended to the output file. Defaults to `NULL`.

- prefix:

  Character. Prefix for the output file name. Defaults to `"S"`.

## Value

Invisible `NULL`. Used for its side effect of writing session
information to a file.

## Examples

``` r
load_packages(fs)

# Save session info without object details
temp_dir <- fs::path_temp("save_session_info")
fs::dir_create(temp_dir)

save_session_info(out_directory = temp_dir)
#> Saving session info to:
#> /tmp/Rtmp9s80iV/save_session_info/S_20251109_1856.txt

saved_file <- list.files(
  temp_dir, pattern = "S_.+txt$", full.names = TRUE) %>%
  ecokit::normalize_path()
(saved_file <- saved_file[length(saved_file)])
#> /tmp/Rtmp9s80iV/save_session_info/S_20251109_1856.txt

cat(readLines(saved_file), sep = "\n")
#> 
#> --------------------------------------------------
#> Session Info
#> --------------------------------------------------
#> 
#> ─ Session info ───────────────────────────────────────────────────────────────
#>  setting  value
#>  version  R version 4.5.2 (2025-10-31)
#>  os       Ubuntu 24.04.3 LTS
#>  system   x86_64, linux-gnu
#>  ui       X11
#>  language en-GB
#>  collate  C
#>  ctype    C.UTF-8
#>  tz       UTC
#>  date     2025-11-09
#>  pandoc   3.1.11 @ /opt/hostedtoolcache/pandoc/3.1.11/x64/ (via rmarkdown)
#>  quarto   NA
#> 
#> ─ Packages ───────────────────────────────────────────────────────────────────
#>  package      * version  date (UTC) lib source
#>  abind          1.4-8    2024-09-12 [1] RSPM
#>  arrow        * 22.0.0   2025-10-29 [1] RSPM
#>  askpass        1.2.1    2024-10-04 [1] RSPM
#>  assertthat     0.2.1    2019-03-21 [1] RSPM
#>  bit            4.6.0    2025-03-06 [1] RSPM
#>  bit64          4.6.0-1  2025-01-16 [1] RSPM
#>  bslib          0.9.0    2025-01-30 [1] RSPM
#>  cachem         1.1.0    2024-05-16 [1] RSPM
#>  callr          3.7.6    2024-03-25 [1] RSPM
#>  car          * 3.1-3    2024-09-27 [1] RSPM
#>  carData      * 3.0-5    2022-01-06 [1] RSPM
#>  class          7.3-23   2025-01-01 [3] CRAN (R 4.5.2)
#>  classInt       0.4-11   2025-01-08 [1] RSPM
#>  cli            3.6.5    2025-04-23 [1] RSPM
#>  codetools      0.2-20   2024-03-31 [3] CRAN (R 4.5.2)
#>  cowplot        1.2.0    2025-07-07 [1] RSPM
#>  crayon         1.5.3    2024-06-20 [1] RSPM
#>  curl           7.0.0    2025-08-19 [1] RSPM
#>  data.table     1.17.8   2025-07-10 [1] RSPM
#>  DBI            1.2.3    2024-06-02 [1] RSPM
#>  desc           1.4.3    2023-12-10 [1] RSPM
#>  devtools       2.4.6    2025-10-03 [1] RSPM
#>  digest         0.6.37   2024-08-19 [1] RSPM
#>  dismo        * 1.3-16   2024-11-25 [1] RSPM
#>  dotCall64      1.2      2024-10-04 [1] RSPM
#>  downlit        0.4.4    2024-06-10 [1] RSPM
#>  dplyr        * 1.1.4    2023-11-17 [1] RSPM
#>  e1071          1.7-16   2024-09-16 [1] RSPM
#>  ecokit       * 0.1.0    2025-11-09 [1] local
#>  ellipsis       0.3.2    2021-04-29 [1] RSPM
#>  evaluate       1.0.5    2025-08-27 [1] RSPM
#>  fansi          1.0.6    2023-12-08 [1] RSPM
#>  farver         2.1.2    2024-05-13 [1] RSPM
#>  fastmap        1.2.0    2024-05-15 [1] RSPM
#>  fields         17.1     2025-09-08 [1] RSPM
#>  fontawesome    0.5.3    2024-11-16 [1] RSPM
#>  Formula        1.2-5    2023-02-24 [1] RSPM
#>  fs           * 1.6.6    2025-04-12 [1] RSPM
#>  future       * 1.67.0   2025-07-29 [1] RSPM
#>  future.apply   1.20.0   2025-06-06 [1] RSPM
#>  gdata          3.0.1    2024-10-22 [1] RSPM
#>  generics       0.1.4    2025-05-09 [1] RSPM
#>  ggplot2      * 4.0.0    2025-09-11 [1] RSPM
#>  globals        0.18.0   2025-05-08 [1] RSPM
#>  glue           1.8.0    2024-09-30 [1] RSPM
#>  gtable         0.3.6    2024-10-25 [1] RSPM
#>  gtools         3.9.5    2023-11-20 [1] RSPM
#>  htmltools      0.5.8.1  2024-04-04 [1] RSPM
#>  htmlwidgets    1.6.4    2023-12-06 [1] RSPM
#>  httr           1.4.7    2023-08-15 [1] RSPM
#>  httr2          1.2.1    2025-07-22 [1] RSPM
#>  jquerylib      0.1.4    2021-04-26 [1] RSPM
#>  jsonlite       2.0.0    2025-03-27 [1] RSPM
#>  KernSmooth     2.23-26  2025-01-01 [3] CRAN (R 4.5.2)
#>  knitr          1.50     2025-03-16 [1] RSPM
#>  labeling       0.4.3    2023-08-29 [1] RSPM
#>  lattice        0.22-7   2025-04-02 [3] CRAN (R 4.5.2)
#>  lifecycle      1.0.4    2023-11-07 [1] RSPM
#>  listenv        0.10.0   2025-11-02 [1] RSPM
#>  lobstr         1.1.2    2022-06-22 [1] RSPM
#>  lubridate    * 1.9.4    2024-12-08 [1] RSPM
#>  magrittr     * 2.0.4    2025-09-12 [1] RSPM
#>  maps           3.4.3    2025-05-26 [1] RSPM
#>  MASS           7.3-65   2025-02-28 [3] CRAN (R 4.5.2)
#>  memoise        2.0.1    2021-11-26 [1] RSPM
#>  nnet         * 7.3-20   2025-01-01 [3] CRAN (R 4.5.2)
#>  openssl        2.3.4    2025-09-30 [1] RSPM
#>  pak            0.9.0    2025-05-27 [1] RSPM
#>  parallelly     1.45.1   2025-07-24 [1] RSPM
#>  pillar         1.11.1   2025-09-17 [1] RSPM
#>  pkgbuild       1.4.8    2025-05-26 [1] RSPM
#>  pkgconfig      2.0.3    2019-09-22 [1] RSPM
#>  pkgdown        2.2.0    2025-11-06 [1] RSPM
#>  pkgload        1.4.1    2025-09-23 [1] RSPM
#>  png          * 0.1-8    2022-11-29 [1] RSPM
#>  processx       3.8.6    2025-02-21 [1] RSPM
#>  proxy          0.4-27   2022-06-09 [1] RSPM
#>  ps             1.9.1    2025-04-12 [1] RSPM
#>  purrr        * 1.2.0    2025-11-04 [1] RSPM
#>  qs2          * 0.1.5    2025-03-07 [1] RSPM
#>  R6             2.6.1    2025-02-15 [1] RSPM
#>  ragg           1.5.0    2025-09-02 [1] RSPM
#>  rappdirs       0.3.3    2021-01-31 [1] RSPM
#>  raster       * 3.6-32   2025-03-28 [1] RSPM
#>  RColorBrewer   1.1-3    2022-04-03 [1] RSPM
#>  Rcpp           1.1.0    2025-07-02 [1] RSPM
#>  RcppParallel   5.1.11-1 2025-08-27 [1] RSPM
#>  remotes      * 2.5.0    2024-03-17 [1] RSPM
#>  rJava        * 1.0-11   2024-01-26 [1] RSPM
#>  rlang          1.1.6    2025-04-11 [1] RSPM
#>  rmarkdown      2.30     2025-09-28 [1] RSPM
#>  RNetCDF        2.11-1   2025-04-30 [1] RSPM
#>  rstudioapi     0.17.1   2024-10-22 [1] RSPM
#>  rvest          1.0.5    2025-08-29 [1] RSPM
#>  rworldmap    * 1.3-8    2023-10-16 [1] RSPM
#>  s2             1.1.9    2025-05-23 [1] RSPM
#>  S7             0.2.0    2024-11-07 [1] RSPM
#>  sass           0.4.10   2025-04-11 [1] RSPM
#>  scales       * 1.4.0    2025-04-24 [1] RSPM
#>  selectr        0.4-2    2019-11-20 [1] RSPM
#>  sessioninfo    1.2.3    2025-02-05 [1] RSPM
#>  sf           * 1.0-21   2025-05-15 [1] RSPM
#>  sp           * 2.2-0    2025-02-01 [1] RSPM
#>  spam           2.11-1   2025-01-20 [1] RSPM
#>  stringfish     0.17.0   2025-07-13 [1] RSPM
#>  stringi        1.8.7    2025-03-27 [1] RSPM
#>  stringr      * 1.6.0    2025-11-04 [1] RSPM
#>  systemfonts    1.3.1    2025-10-01 [1] RSPM
#>  terra        * 1.8-80   2025-11-05 [1] RSPM
#>  textshaping    1.0.4    2025-10-10 [1] RSPM
#>  tibble       * 3.3.0    2025-06-08 [1] RSPM
#>  tidyr        * 1.3.1    2024-01-24 [1] RSPM
#>  tidyselect     1.2.1    2024-03-11 [1] RSPM
#>  tidyterra    * 0.7.2    2025-04-14 [1] RSPM
#>  timechange     0.3.0    2024-01-18 [1] RSPM
#>  units          1.0-0    2025-10-09 [1] RSPM
#>  usethis        3.2.1    2025-09-06 [1] RSPM
#>  utf8           1.2.6    2025-06-08 [1] RSPM
#>  vctrs          0.6.5    2023-12-01 [1] RSPM
#>  viridisLite    0.4.2    2023-05-02 [1] RSPM
#>  whisker        0.4.1    2022-12-05 [1] RSPM
#>  withr          3.0.2    2024-10-28 [1] RSPM
#>  wk             0.9.4    2024-10-11 [1] RSPM
#>  xfun           0.54     2025-10-30 [1] RSPM
#>  xml2           1.4.1    2025-10-27 [1] RSPM
#>  yaml           2.3.10   2024-07-26 [1] RSPM
#> 
#>  [1] /home/runner/work/_temp/Library
#>  [2] /opt/R/4.5.2/lib/R/site-library
#>  [3] /opt/R/4.5.2/lib/R/library
#>  * ── Packages attached to the search path.
#> 
#> ──────────────────────────────────────────────────────────────────────────────

# |||||||||||||||||||||||||||||||||||||||||||||||||

# Save session info with object details
# Create sample objects
df <- data.frame(a = 1:1000)
vec <- rnorm(1000)

# Simulate output from save_session()
session_data <- tibble::tibble(object = c("df", "vec"), size = c(0.1, 0.1))
save_session_info(out_directory = temp_dir, session_info = session_data)
#> Saving session info to:
#> /tmp/Rtmp9s80iV/save_session_info/S_20251109_1856.txt

saved_file <- list.files(
  temp_dir, pattern = "S_.+txt$", full.names = TRUE) %>%
  ecokit::normalize_path()
(saved_file <- saved_file[length(saved_file)])
#> /tmp/Rtmp9s80iV/save_session_info/S_20251109_1856.txt

cat(readLines(saved_file), sep = "\n")
#> 
#> --------------------------------------------------
#> Session Info
#> --------------------------------------------------
#> 
#> ─ Session info ───────────────────────────────────────────────────────────────
#>  setting  value
#>  version  R version 4.5.2 (2025-10-31)
#>  os       Ubuntu 24.04.3 LTS
#>  system   x86_64, linux-gnu
#>  ui       X11
#>  language en-GB
#>  collate  C
#>  ctype    C.UTF-8
#>  tz       UTC
#>  date     2025-11-09
#>  pandoc   3.1.11 @ /opt/hostedtoolcache/pandoc/3.1.11/x64/ (via rmarkdown)
#>  quarto   NA
#> 
#> ─ Packages ───────────────────────────────────────────────────────────────────
#>  package      * version  date (UTC) lib source
#>  abind          1.4-8    2024-09-12 [1] RSPM
#>  arrow        * 22.0.0   2025-10-29 [1] RSPM
#>  askpass        1.2.1    2024-10-04 [1] RSPM
#>  assertthat     0.2.1    2019-03-21 [1] RSPM
#>  bit            4.6.0    2025-03-06 [1] RSPM
#>  bit64          4.6.0-1  2025-01-16 [1] RSPM
#>  bslib          0.9.0    2025-01-30 [1] RSPM
#>  cachem         1.1.0    2024-05-16 [1] RSPM
#>  callr          3.7.6    2024-03-25 [1] RSPM
#>  car          * 3.1-3    2024-09-27 [1] RSPM
#>  carData      * 3.0-5    2022-01-06 [1] RSPM
#>  class          7.3-23   2025-01-01 [3] CRAN (R 4.5.2)
#>  classInt       0.4-11   2025-01-08 [1] RSPM
#>  cli            3.6.5    2025-04-23 [1] RSPM
#>  codetools      0.2-20   2024-03-31 [3] CRAN (R 4.5.2)
#>  cowplot        1.2.0    2025-07-07 [1] RSPM
#>  crayon         1.5.3    2024-06-20 [1] RSPM
#>  curl           7.0.0    2025-08-19 [1] RSPM
#>  data.table     1.17.8   2025-07-10 [1] RSPM
#>  DBI            1.2.3    2024-06-02 [1] RSPM
#>  desc           1.4.3    2023-12-10 [1] RSPM
#>  devtools       2.4.6    2025-10-03 [1] RSPM
#>  digest         0.6.37   2024-08-19 [1] RSPM
#>  dismo        * 1.3-16   2024-11-25 [1] RSPM
#>  dotCall64      1.2      2024-10-04 [1] RSPM
#>  downlit        0.4.4    2024-06-10 [1] RSPM
#>  dplyr        * 1.1.4    2023-11-17 [1] RSPM
#>  e1071          1.7-16   2024-09-16 [1] RSPM
#>  ecokit       * 0.1.0    2025-11-09 [1] local
#>  ellipsis       0.3.2    2021-04-29 [1] RSPM
#>  evaluate       1.0.5    2025-08-27 [1] RSPM
#>  fansi          1.0.6    2023-12-08 [1] RSPM
#>  farver         2.1.2    2024-05-13 [1] RSPM
#>  fastmap        1.2.0    2024-05-15 [1] RSPM
#>  fields         17.1     2025-09-08 [1] RSPM
#>  fontawesome    0.5.3    2024-11-16 [1] RSPM
#>  Formula        1.2-5    2023-02-24 [1] RSPM
#>  fs           * 1.6.6    2025-04-12 [1] RSPM
#>  future       * 1.67.0   2025-07-29 [1] RSPM
#>  future.apply   1.20.0   2025-06-06 [1] RSPM
#>  gdata          3.0.1    2024-10-22 [1] RSPM
#>  generics       0.1.4    2025-05-09 [1] RSPM
#>  ggplot2      * 4.0.0    2025-09-11 [1] RSPM
#>  globals        0.18.0   2025-05-08 [1] RSPM
#>  glue           1.8.0    2024-09-30 [1] RSPM
#>  gtable         0.3.6    2024-10-25 [1] RSPM
#>  gtools         3.9.5    2023-11-20 [1] RSPM
#>  htmltools      0.5.8.1  2024-04-04 [1] RSPM
#>  htmlwidgets    1.6.4    2023-12-06 [1] RSPM
#>  httr           1.4.7    2023-08-15 [1] RSPM
#>  httr2          1.2.1    2025-07-22 [1] RSPM
#>  jquerylib      0.1.4    2021-04-26 [1] RSPM
#>  jsonlite       2.0.0    2025-03-27 [1] RSPM
#>  KernSmooth     2.23-26  2025-01-01 [3] CRAN (R 4.5.2)
#>  knitr          1.50     2025-03-16 [1] RSPM
#>  labeling       0.4.3    2023-08-29 [1] RSPM
#>  lattice        0.22-7   2025-04-02 [3] CRAN (R 4.5.2)
#>  lifecycle      1.0.4    2023-11-07 [1] RSPM
#>  listenv        0.10.0   2025-11-02 [1] RSPM
#>  lobstr         1.1.2    2022-06-22 [1] RSPM
#>  lubridate    * 1.9.4    2024-12-08 [1] RSPM
#>  magrittr     * 2.0.4    2025-09-12 [1] RSPM
#>  maps           3.4.3    2025-05-26 [1] RSPM
#>  MASS           7.3-65   2025-02-28 [3] CRAN (R 4.5.2)
#>  memoise        2.0.1    2021-11-26 [1] RSPM
#>  nnet         * 7.3-20   2025-01-01 [3] CRAN (R 4.5.2)
#>  openssl        2.3.4    2025-09-30 [1] RSPM
#>  pak            0.9.0    2025-05-27 [1] RSPM
#>  parallelly     1.45.1   2025-07-24 [1] RSPM
#>  pillar         1.11.1   2025-09-17 [1] RSPM
#>  pkgbuild       1.4.8    2025-05-26 [1] RSPM
#>  pkgconfig      2.0.3    2019-09-22 [1] RSPM
#>  pkgdown        2.2.0    2025-11-06 [1] RSPM
#>  pkgload        1.4.1    2025-09-23 [1] RSPM
#>  png          * 0.1-8    2022-11-29 [1] RSPM
#>  processx       3.8.6    2025-02-21 [1] RSPM
#>  proxy          0.4-27   2022-06-09 [1] RSPM
#>  ps             1.9.1    2025-04-12 [1] RSPM
#>  purrr        * 1.2.0    2025-11-04 [1] RSPM
#>  qs2          * 0.1.5    2025-03-07 [1] RSPM
#>  R6             2.6.1    2025-02-15 [1] RSPM
#>  ragg           1.5.0    2025-09-02 [1] RSPM
#>  rappdirs       0.3.3    2021-01-31 [1] RSPM
#>  raster       * 3.6-32   2025-03-28 [1] RSPM
#>  RColorBrewer   1.1-3    2022-04-03 [1] RSPM
#>  Rcpp           1.1.0    2025-07-02 [1] RSPM
#>  RcppParallel   5.1.11-1 2025-08-27 [1] RSPM
#>  remotes      * 2.5.0    2024-03-17 [1] RSPM
#>  rJava        * 1.0-11   2024-01-26 [1] RSPM
#>  rlang          1.1.6    2025-04-11 [1] RSPM
#>  rmarkdown      2.30     2025-09-28 [1] RSPM
#>  RNetCDF        2.11-1   2025-04-30 [1] RSPM
#>  rstudioapi     0.17.1   2024-10-22 [1] RSPM
#>  rvest          1.0.5    2025-08-29 [1] RSPM
#>  rworldmap    * 1.3-8    2023-10-16 [1] RSPM
#>  s2             1.1.9    2025-05-23 [1] RSPM
#>  S7             0.2.0    2024-11-07 [1] RSPM
#>  sass           0.4.10   2025-04-11 [1] RSPM
#>  scales       * 1.4.0    2025-04-24 [1] RSPM
#>  selectr        0.4-2    2019-11-20 [1] RSPM
#>  sessioninfo    1.2.3    2025-02-05 [1] RSPM
#>  sf           * 1.0-21   2025-05-15 [1] RSPM
#>  sp           * 2.2-0    2025-02-01 [1] RSPM
#>  spam           2.11-1   2025-01-20 [1] RSPM
#>  stringfish     0.17.0   2025-07-13 [1] RSPM
#>  stringi        1.8.7    2025-03-27 [1] RSPM
#>  stringr      * 1.6.0    2025-11-04 [1] RSPM
#>  systemfonts    1.3.1    2025-10-01 [1] RSPM
#>  terra        * 1.8-80   2025-11-05 [1] RSPM
#>  textshaping    1.0.4    2025-10-10 [1] RSPM
#>  tibble       * 3.3.0    2025-06-08 [1] RSPM
#>  tidyr        * 1.3.1    2024-01-24 [1] RSPM
#>  tidyselect     1.2.1    2024-03-11 [1] RSPM
#>  tidyterra    * 0.7.2    2025-04-14 [1] RSPM
#>  timechange     0.3.0    2024-01-18 [1] RSPM
#>  units          1.0-0    2025-10-09 [1] RSPM
#>  usethis        3.2.1    2025-09-06 [1] RSPM
#>  utf8           1.2.6    2025-06-08 [1] RSPM
#>  vctrs          0.6.5    2023-12-01 [1] RSPM
#>  viridisLite    0.4.2    2023-05-02 [1] RSPM
#>  whisker        0.4.1    2022-12-05 [1] RSPM
#>  withr          3.0.2    2024-10-28 [1] RSPM
#>  wk             0.9.4    2024-10-11 [1] RSPM
#>  xfun           0.54     2025-10-30 [1] RSPM
#>  xml2           1.4.1    2025-10-27 [1] RSPM
#>  yaml           2.3.10   2024-07-26 [1] RSPM
#> 
#>  [1] /home/runner/work/_temp/Library
#>  [2] /opt/R/4.5.2/lib/R/site-library
#>  [3] /opt/R/4.5.2/lib/R/library
#>  * ── Packages attached to the search path.
#> 
#> ──────────────────────────────────────────────────────────────────────────────
#> 
#> --------------------------------------------------
#> Objects in the current session
#> (except functions and pre-selected objects; Size in megabytes)
#> --------------------------------------------------
#> 
#>  object size
#>      df  0.1
#>     vec  0.1

# clean up
fs::dir_delete(temp_dir)
```
