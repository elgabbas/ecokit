# CHELSA Variable Information

Provides detailed information about variables in the CHELSA
(Climatologies at High Resolution for the Earth's Land Surface Areas)
dataset, including names, units, and descriptions.

## Usage

``` r
chelsa_var_info
```

## Format

A tibble with 47 rows and 6 columns:

- `var_name` (character): Variable short name, e.g., "bio1".

- `long_name` (character): Full variable name, e.g., "mean annual air
  temperature".

- `unit` (character): Measurement unit, e.g., "°C".

- `scale` (numeric): Scale factor applied to the variable.

- `offset` (numeric): Offset value applied to the variable.

- `explanation` (character): Description of the variable.

## Source

<https://chelsa-climate.org/wp-admin/download-page/CHELSA_tech_specification_V2.pdf>

## Examples

``` r
# Load the CHELSA variable information
library(ecokit)
library(tibble)
options(pillar.print_max = 64)

data("chelsa_var_info", package = "ecokit")
ecokit::ht(chelsa_var_info)
#>     var_name                                               long_name
#>       <char>                                                  <char>
#>  1:     bio1                             mean annual air temperature
#>  2:     bio2                      mean diurnal air temperature range
#>  3:     bio3                                           isothermality
#>  4:     bio4                                 temperature seasonality
#>  5:     bio5 mean daily maximum air temperature of the warmest month
#> ---                                                                 
#> 42:     ngd5                           Number of growing degree days
#> 43:    ngd10                           Number of growing degree days
#> 44:      npp                                Net primary productivity
#> 45:      scd                                         Snow cover days
#> 46:      swe                                   Snow water equivalent
#>               unit scale  offset
#>             <char> <num>   <num>
#>  1:             °C   0.1 -273.15
#>  2:             °C   0.1    0.00
#>  3:             °C   0.1    0.00
#>  4:         °C/100   0.1    0.00
#>  5:             °C   0.1 -273.15
#> ---                             
#> 42: number of days    NA      NA
#> 43: number of days    NA      NA
#> 44:   g C m−2 yr−1   0.1    0.00
#> 45:          count    NA      NA
#> 46:  kg m-2 year-1   0.1    0.00
#>                                                                                                                                                explanation
#>                                                                                                                                                     <char>
#>  1:                                                                                           mean annual daily mean air temperatures averaged over 1 year
#>  2:                                                                                                mean diurnal range of temperatures averaged over 1 year
#>  3:                                                                                         ratio of diurnal variation to annual variation in temperatures
#>  4:                                                                                                    standard deviation of the monthly mean temperatures
#>  5:                                                                                  The highest temperature of any monthly daily mean maximum temperature
#> ---                                                                                                                                                       
#> 42:                                                                                                                      Number of days at which tas > 5°C
#> 43:                                                                                                                     Number of days at which tas > 10°C
#> 44: Calculated based on the ‘Miami model’, Lieth, H., 1972. "Modelling the primary productivity of the earth. Nature and resources", UNESCO, VIII, 2:5-10.
#> 45:            Number of days with snowcover calculated using the snowpack model implementation in from TREELIM (https://doi.org/10.1007/s00035-0140124-0)
#> 46:                                                                                                               Amount of liquid water if snow is melted
```
