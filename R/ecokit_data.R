#' CHELSA Variable Information
#'
#' Provides detailed information about variables in the CHELSA (Climatologies at
#' High Resolution for the Earth's Land Surface Areas) dataset, including names,
#' units, and descriptions.
#' @format A tibble with 47 rows and 6 columns:
#' - `var_name` (character): Variable short name, e.g., "bio1".
#' - `long_name` (character): Full variable name, e.g., "mean annual air
#'   temperature".
#' - `unit` (character): Measurement unit, e.g., "°C".
#' - `scale` (numeric): Scale factor applied to the variable.
#' - `offset` (numeric): Offset value applied to the variable.
#' - `explanation` (character): Description of the variable.
#' @name chelsa_var_info
#' @source
#' <https://chelsa-climate.org/wp-admin/download-page/CHELSA_tech_specification_V2.pdf>
#'
#' @examples
#' # Load the CHELSA variable information
#' library(ecokit)
#' library(tibble)
#' options(pillar.print_max = 64)
#'
#' data("chelsa_var_info", package = "ecokit")
#' print(chelsa_var_info, n = Inf)
"chelsa_var_info"
