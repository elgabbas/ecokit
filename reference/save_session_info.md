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
#> /tmp/RtmpOCEThP/save_session_info/S_20260603_0729.txt

saved_file <- list.files(
  temp_dir, pattern = "S_.+txt$", full.names = TRUE) %>%
  ecokit::normalize_path()
(saved_file <- saved_file[length(saved_file)])
#> /tmp/RtmpOCEThP/save_session_info/S_20260603_0729.txt

cat(readLines(saved_file), sep = "\n")
#> 
#> --------------------------------------------------
#> Session Info
#> --------------------------------------------------
#> 
#> ─ Session info ───────────────────────────────────────────────────────────────
#>  setting  value
#>  version  R version 4.6.0 (2026-04-24)
#>  os       Ubuntu 24.04.4 LTS
#>  system   x86_64, linux-gnu
#>  ui       X11
#>  language en-GB
#>  collate  C
#>  ctype    C.UTF-8
#>  tz       UTC
#>  date     2026-06-03
#>  pandoc   3.8.3 @ /opt/hostedtoolcache/pandoc/3.8.3/x64/ (via rmarkdown)
#>  quarto   NA
#> 
#> ─ Packages ───────────────────────────────────────────────────────────────────
#>  package      * version   date (UTC) lib source
#>  abind          1.4-8     2024-09-12 [1] RSPM
#>  arrow        * 24.0.0    2026-04-29 [1] RSPM
#>  askpass        1.2.1     2024-10-04 [1] RSPM
#>  assertthat     0.2.1     2019-03-21 [1] RSPM
#>  bit            4.6.0     2025-03-06 [1] RSPM
#>  bit64          4.8.2     2026-05-19 [1] RSPM
#>  bslib          0.11.0    2026-05-16 [1] RSPM
#>  cachem         1.1.0     2024-05-16 [1] RSPM
#>  callr          3.7.6     2024-03-25 [1] RSPM
#>  car          * 3.1-5     2026-02-03 [1] RSPM
#>  carData      * 3.0-6     2026-01-30 [1] RSPM
#>  class          7.3-23    2025-01-01 [3] CRAN (R 4.6.0)
#>  classInt       0.4-11    2025-01-08 [1] RSPM
#>  cli            3.6.6     2026-04-09 [1] RSPM
#>  codetools      0.2-20    2024-03-31 [3] CRAN (R 4.6.0)
#>  cowplot        1.2.0     2025-07-07 [1] RSPM
#>  crayon         1.5.3     2024-06-20 [1] RSPM
#>  crul           1.6.0     2025-07-23 [1] RSPM
#>  curl           7.1.0     2026-04-22 [1] RSPM
#>  data.table     1.18.4    2026-05-06 [1] RSPM
#>  DBI            1.3.0     2026-02-25 [1] RSPM
#>  desc           1.4.3     2023-12-10 [1] RSPM
#>  digest         0.6.39    2025-11-19 [1] RSPM
#>  dismo        * 1.3-16    2024-11-25 [1] RSPM
#>  dotCall64      1.2       2024-10-04 [1] RSPM
#>  downlit        0.4.5     2025-11-14 [1] RSPM
#>  dplyr        * 1.2.1     2026-04-03 [1] RSPM
#>  e1071          1.7-17    2025-12-18 [1] RSPM
#>  ecokit       * 0.1.0     2026-06-03 [1] local
#>  evaluate       1.0.5     2025-08-27 [1] RSPM
#>  fansi          1.0.7     2025-11-19 [1] RSPM
#>  farver         2.1.2     2024-05-13 [1] RSPM
#>  fastmap        1.2.0     2024-05-15 [1] RSPM
#>  fields         17.3      2026-05-05 [1] RSPM
#>  fontawesome    0.5.3     2024-11-16 [1] RSPM
#>  Formula        1.2-5     2023-02-24 [1] RSPM
#>  fs           * 2.1.0     2026-04-18 [1] RSPM
#>  future       * 1.70.0    2026-03-14 [1] RSPM
#>  future.apply   1.20.2    2026-02-20 [1] RSPM
#>  gdata          3.0.1     2024-10-22 [1] RSPM
#>  generics       0.1.4     2025-05-09 [1] RSPM
#>  ggplot2      * 4.0.3     2026-04-22 [1] RSPM
#>  globals        0.19.1    2026-03-13 [1] RSPM
#>  glue           1.8.1     2026-04-17 [1] RSPM
#>  gtable         0.3.6     2024-10-25 [1] RSPM
#>  gtools         3.9.5     2023-11-20 [1] RSPM
#>  htmltools      0.5.9     2025-12-04 [1] RSPM
#>  htmlwidgets    1.6.4     2023-12-06 [1] RSPM
#>  httpcode       0.3.0     2020-04-10 [1] RSPM
#>  httr           1.4.8     2026-02-13 [1] RSPM
#>  httr2          1.2.2     2025-12-08 [1] RSPM
#>  jquerylib      0.1.4     2021-04-26 [1] RSPM
#>  jsonlite       2.0.0     2025-03-27 [1] RSPM
#>  KernSmooth     2.23-26   2025-01-01 [3] CRAN (R 4.6.0)
#>  knitr          1.51      2025-12-20 [1] RSPM
#>  labeling       0.4.3     2023-08-29 [1] RSPM
#>  lattice        0.22-9    2026-02-09 [3] CRAN (R 4.6.0)
#>  lifecycle      1.0.5     2026-01-08 [1] RSPM
#>  listenv        0.10.1    2026-03-10 [1] RSPM
#>  lobstr         1.2.1     2026-04-04 [1] RSPM
#>  lubridate    * 1.9.5     2026-02-04 [1] RSPM
#>  magrittr     * 2.0.5     2026-04-04 [1] RSPM
#>  maps           3.4.3     2025-05-26 [1] RSPM
#>  MASS           7.3-65    2025-02-28 [3] CRAN (R 4.6.0)
#>  memoise        2.0.1     2021-11-26 [1] RSPM
#>  nnet         * 7.3-20    2025-01-01 [3] CRAN (R 4.6.0)
#>  openssl        2.4.1     2026-05-14 [1] RSPM
#>  osfr           0.2.9     2022-09-25 [1] RSPM
#>  otel           0.2.0     2025-08-29 [1] RSPM
#>  pak            0.9.5     2026-04-27 [1] RSPM
#>  parallelly     1.47.0    2026-04-17 [1] RSPM
#>  pillar         1.11.1    2025-09-17 [1] RSPM
#>  pkgbuild       1.4.8     2025-05-26 [1] RSPM
#>  pkgconfig      2.0.3     2019-09-22 [1] RSPM
#>  pkgdown        2.2.0     2025-11-06 [1] RSPM
#>  png          * 0.1-9     2026-03-15 [1] RSPM
#>  processx       3.9.0     2026-04-22 [1] RSPM
#>  proxy          0.4-29    2025-12-29 [1] RSPM
#>  ps             1.9.3     2026-04-20 [1] RSPM
#>  purrr        * 1.2.2     2026-04-10 [1] RSPM
#>  qs2          * 0.2.1     2026-05-04 [1] RSPM
#>  R6             2.6.1     2025-02-15 [1] RSPM
#>  ragg           1.5.2     2026-03-23 [1] RSPM
#>  RANN           2.6.2     2024-08-25 [1] RSPM
#>  rappdirs       0.3.4     2026-01-17 [1] RSPM
#>  raster       * 3.6-32    2025-03-28 [1] RSPM
#>  RColorBrewer   1.1-3     2022-04-03 [1] RSPM
#>  Rcpp           1.1.1-1.1 2026-04-24 [1] RSPM
#>  RcppParallel   5.1.11-2  2026-03-05 [1] RSPM
#>  remotes      * 2.5.0     2024-03-17 [1] RSPM
#>  rJava        * 1.0-18    2026-04-08 [1] RSPM
#>  rlang          1.2.0     2026-04-06 [1] RSPM
#>  rmarkdown      2.31      2026-03-26 [1] RSPM
#>  RNetCDF        2.11-1    2025-04-30 [1] RSPM
#>  rstudioapi     0.18.0    2026-01-16 [1] RSPM
#>  rvest          1.0.5     2025-08-29 [1] RSPM
#>  rworldmap    * 1.3-8     2023-10-16 [1] RSPM
#>  s2             1.1.11    2026-06-01 [1] RSPM
#>  S7             0.2.2     2026-04-22 [1] RSPM
#>  sass           0.4.10    2025-04-11 [1] RSPM
#>  scales       * 1.4.0     2025-04-24 [1] RSPM
#>  selectr        0.5-1     2025-12-17 [1] RSPM
#>  sessioninfo    1.2.3     2025-02-05 [1] RSPM
#>  sf           * 1.1-1     2026-05-06 [1] RSPM
#>  sp           * 2.2-1     2026-02-13 [1] RSPM
#>  spam           2.11-4    2026-05-29 [1] RSPM
#>  stringfish     0.19.0    2026-04-21 [1] RSPM
#>  stringi        1.8.7     2025-03-27 [1] RSPM
#>  stringr      * 1.6.0     2025-11-04 [1] RSPM
#>  systemfonts    1.3.2     2026-03-05 [1] RSPM
#>  terra        * 1.9-27    2026-05-10 [1] RSPM
#>  textshaping    1.0.5     2026-03-06 [1] RSPM
#>  tibble       * 3.3.1     2026-01-11 [1] RSPM
#>  tidyr        * 1.3.2     2025-12-19 [1] RSPM
#>  tidyselect     1.2.1     2024-03-11 [1] RSPM
#>  tidyterra    * 1.1.0     2026-03-11 [1] RSPM
#>  timechange     0.4.0     2026-01-29 [1] RSPM
#>  triebeard      0.4.1     2023-03-04 [1] RSPM
#>  units          1.0-1     2026-03-11 [1] RSPM
#>  urltools       1.7.3.1   2025-06-12 [1] RSPM
#>  utf8           1.2.6     2025-06-08 [1] RSPM
#>  vctrs          0.7.3     2026-04-11 [1] RSPM
#>  viridisLite    0.4.3     2026-02-04 [1] RSPM
#>  whisker        0.4.1     2022-12-05 [1] RSPM
#>  withr          3.0.2     2024-10-28 [1] RSPM
#>  wk             0.9.5     2025-12-18 [1] RSPM
#>  xfun           0.58      2026-06-01 [1] RSPM
#>  xml2           1.5.2     2026-01-17 [1] RSPM
#>  yaml           2.3.12    2025-12-10 [1] RSPM
#> 
#>  [1] /home/runner/work/_temp/Library
#>  [2] /opt/R/4.6.0/lib/R/site-library
#>  [3] /opt/R/4.6.0/lib/R/library
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
#> /tmp/RtmpOCEThP/save_session_info/S_20260603_0729.txt

saved_file <- list.files(
  temp_dir, pattern = "S_.+txt$", full.names = TRUE) %>%
  ecokit::normalize_path()
(saved_file <- saved_file[length(saved_file)])
#> /tmp/RtmpOCEThP/save_session_info/S_20260603_0729.txt

cat(readLines(saved_file), sep = "\n")
#> 
#> --------------------------------------------------
#> Session Info
#> --------------------------------------------------
#> 
#> ─ Session info ───────────────────────────────────────────────────────────────
#>  setting  value
#>  version  R version 4.6.0 (2026-04-24)
#>  os       Ubuntu 24.04.4 LTS
#>  system   x86_64, linux-gnu
#>  ui       X11
#>  language en-GB
#>  collate  C
#>  ctype    C.UTF-8
#>  tz       UTC
#>  date     2026-06-03
#>  pandoc   3.8.3 @ /opt/hostedtoolcache/pandoc/3.8.3/x64/ (via rmarkdown)
#>  quarto   NA
#> 
#> ─ Packages ───────────────────────────────────────────────────────────────────
#>  package      * version   date (UTC) lib source
#>  abind          1.4-8     2024-09-12 [1] RSPM
#>  arrow        * 24.0.0    2026-04-29 [1] RSPM
#>  askpass        1.2.1     2024-10-04 [1] RSPM
#>  assertthat     0.2.1     2019-03-21 [1] RSPM
#>  bit            4.6.0     2025-03-06 [1] RSPM
#>  bit64          4.8.2     2026-05-19 [1] RSPM
#>  bslib          0.11.0    2026-05-16 [1] RSPM
#>  cachem         1.1.0     2024-05-16 [1] RSPM
#>  callr          3.7.6     2024-03-25 [1] RSPM
#>  car          * 3.1-5     2026-02-03 [1] RSPM
#>  carData      * 3.0-6     2026-01-30 [1] RSPM
#>  class          7.3-23    2025-01-01 [3] CRAN (R 4.6.0)
#>  classInt       0.4-11    2025-01-08 [1] RSPM
#>  cli            3.6.6     2026-04-09 [1] RSPM
#>  codetools      0.2-20    2024-03-31 [3] CRAN (R 4.6.0)
#>  cowplot        1.2.0     2025-07-07 [1] RSPM
#>  crayon         1.5.3     2024-06-20 [1] RSPM
#>  crul           1.6.0     2025-07-23 [1] RSPM
#>  curl           7.1.0     2026-04-22 [1] RSPM
#>  data.table     1.18.4    2026-05-06 [1] RSPM
#>  DBI            1.3.0     2026-02-25 [1] RSPM
#>  desc           1.4.3     2023-12-10 [1] RSPM
#>  digest         0.6.39    2025-11-19 [1] RSPM
#>  dismo        * 1.3-16    2024-11-25 [1] RSPM
#>  dotCall64      1.2       2024-10-04 [1] RSPM
#>  downlit        0.4.5     2025-11-14 [1] RSPM
#>  dplyr        * 1.2.1     2026-04-03 [1] RSPM
#>  e1071          1.7-17    2025-12-18 [1] RSPM
#>  ecokit       * 0.1.0     2026-06-03 [1] local
#>  evaluate       1.0.5     2025-08-27 [1] RSPM
#>  fansi          1.0.7     2025-11-19 [1] RSPM
#>  farver         2.1.2     2024-05-13 [1] RSPM
#>  fastmap        1.2.0     2024-05-15 [1] RSPM
#>  fields         17.3      2026-05-05 [1] RSPM
#>  fontawesome    0.5.3     2024-11-16 [1] RSPM
#>  Formula        1.2-5     2023-02-24 [1] RSPM
#>  fs           * 2.1.0     2026-04-18 [1] RSPM
#>  future       * 1.70.0    2026-03-14 [1] RSPM
#>  future.apply   1.20.2    2026-02-20 [1] RSPM
#>  gdata          3.0.1     2024-10-22 [1] RSPM
#>  generics       0.1.4     2025-05-09 [1] RSPM
#>  ggplot2      * 4.0.3     2026-04-22 [1] RSPM
#>  globals        0.19.1    2026-03-13 [1] RSPM
#>  glue           1.8.1     2026-04-17 [1] RSPM
#>  gtable         0.3.6     2024-10-25 [1] RSPM
#>  gtools         3.9.5     2023-11-20 [1] RSPM
#>  htmltools      0.5.9     2025-12-04 [1] RSPM
#>  htmlwidgets    1.6.4     2023-12-06 [1] RSPM
#>  httpcode       0.3.0     2020-04-10 [1] RSPM
#>  httr           1.4.8     2026-02-13 [1] RSPM
#>  httr2          1.2.2     2025-12-08 [1] RSPM
#>  jquerylib      0.1.4     2021-04-26 [1] RSPM
#>  jsonlite       2.0.0     2025-03-27 [1] RSPM
#>  KernSmooth     2.23-26   2025-01-01 [3] CRAN (R 4.6.0)
#>  knitr          1.51      2025-12-20 [1] RSPM
#>  labeling       0.4.3     2023-08-29 [1] RSPM
#>  lattice        0.22-9    2026-02-09 [3] CRAN (R 4.6.0)
#>  lifecycle      1.0.5     2026-01-08 [1] RSPM
#>  listenv        0.10.1    2026-03-10 [1] RSPM
#>  lobstr         1.2.1     2026-04-04 [1] RSPM
#>  lubridate    * 1.9.5     2026-02-04 [1] RSPM
#>  magrittr     * 2.0.5     2026-04-04 [1] RSPM
#>  maps           3.4.3     2025-05-26 [1] RSPM
#>  MASS           7.3-65    2025-02-28 [3] CRAN (R 4.6.0)
#>  memoise        2.0.1     2021-11-26 [1] RSPM
#>  nnet         * 7.3-20    2025-01-01 [3] CRAN (R 4.6.0)
#>  openssl        2.4.1     2026-05-14 [1] RSPM
#>  osfr           0.2.9     2022-09-25 [1] RSPM
#>  otel           0.2.0     2025-08-29 [1] RSPM
#>  pak            0.9.5     2026-04-27 [1] RSPM
#>  parallelly     1.47.0    2026-04-17 [1] RSPM
#>  pillar         1.11.1    2025-09-17 [1] RSPM
#>  pkgbuild       1.4.8     2025-05-26 [1] RSPM
#>  pkgconfig      2.0.3     2019-09-22 [1] RSPM
#>  pkgdown        2.2.0     2025-11-06 [1] RSPM
#>  png          * 0.1-9     2026-03-15 [1] RSPM
#>  processx       3.9.0     2026-04-22 [1] RSPM
#>  proxy          0.4-29    2025-12-29 [1] RSPM
#>  ps             1.9.3     2026-04-20 [1] RSPM
#>  purrr        * 1.2.2     2026-04-10 [1] RSPM
#>  qs2          * 0.2.1     2026-05-04 [1] RSPM
#>  R6             2.6.1     2025-02-15 [1] RSPM
#>  ragg           1.5.2     2026-03-23 [1] RSPM
#>  RANN           2.6.2     2024-08-25 [1] RSPM
#>  rappdirs       0.3.4     2026-01-17 [1] RSPM
#>  raster       * 3.6-32    2025-03-28 [1] RSPM
#>  RColorBrewer   1.1-3     2022-04-03 [1] RSPM
#>  Rcpp           1.1.1-1.1 2026-04-24 [1] RSPM
#>  RcppParallel   5.1.11-2  2026-03-05 [1] RSPM
#>  remotes      * 2.5.0     2024-03-17 [1] RSPM
#>  rJava        * 1.0-18    2026-04-08 [1] RSPM
#>  rlang          1.2.0     2026-04-06 [1] RSPM
#>  rmarkdown      2.31      2026-03-26 [1] RSPM
#>  RNetCDF        2.11-1    2025-04-30 [1] RSPM
#>  rstudioapi     0.18.0    2026-01-16 [1] RSPM
#>  rvest          1.0.5     2025-08-29 [1] RSPM
#>  rworldmap    * 1.3-8     2023-10-16 [1] RSPM
#>  s2             1.1.11    2026-06-01 [1] RSPM
#>  S7             0.2.2     2026-04-22 [1] RSPM
#>  sass           0.4.10    2025-04-11 [1] RSPM
#>  scales       * 1.4.0     2025-04-24 [1] RSPM
#>  selectr        0.5-1     2025-12-17 [1] RSPM
#>  sessioninfo    1.2.3     2025-02-05 [1] RSPM
#>  sf           * 1.1-1     2026-05-06 [1] RSPM
#>  sp           * 2.2-1     2026-02-13 [1] RSPM
#>  spam           2.11-4    2026-05-29 [1] RSPM
#>  stringfish     0.19.0    2026-04-21 [1] RSPM
#>  stringi        1.8.7     2025-03-27 [1] RSPM
#>  stringr      * 1.6.0     2025-11-04 [1] RSPM
#>  systemfonts    1.3.2     2026-03-05 [1] RSPM
#>  terra        * 1.9-27    2026-05-10 [1] RSPM
#>  textshaping    1.0.5     2026-03-06 [1] RSPM
#>  tibble       * 3.3.1     2026-01-11 [1] RSPM
#>  tidyr        * 1.3.2     2025-12-19 [1] RSPM
#>  tidyselect     1.2.1     2024-03-11 [1] RSPM
#>  tidyterra    * 1.1.0     2026-03-11 [1] RSPM
#>  timechange     0.4.0     2026-01-29 [1] RSPM
#>  triebeard      0.4.1     2023-03-04 [1] RSPM
#>  units          1.0-1     2026-03-11 [1] RSPM
#>  urltools       1.7.3.1   2025-06-12 [1] RSPM
#>  utf8           1.2.6     2025-06-08 [1] RSPM
#>  vctrs          0.7.3     2026-04-11 [1] RSPM
#>  viridisLite    0.4.3     2026-02-04 [1] RSPM
#>  whisker        0.4.1     2022-12-05 [1] RSPM
#>  withr          3.0.2     2024-10-28 [1] RSPM
#>  wk             0.9.5     2025-12-18 [1] RSPM
#>  xfun           0.58      2026-06-01 [1] RSPM
#>  xml2           1.5.2     2026-01-17 [1] RSPM
#>  yaml           2.3.12    2025-12-10 [1] RSPM
#> 
#>  [1] /home/runner/work/_temp/Library
#>  [2] /opt/R/4.6.0/lib/R/site-library
#>  [3] /opt/R/4.6.0/lib/R/library
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
