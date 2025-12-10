# Retrieve CHELSA Data Links

Fetches links to [CHELSA](https://chelsa-climate.org/) climate data
files from a specified base URL, filters them to include only links for
\*.tif files for variables available under current and future climate
scenarios, and extracts metadata to create a tibble with detailed file
information.

## Usage

``` r
get_chelsa_links(base_url = "https://os.zhdk.cloud.switch.ch/chelsav2/")
```

## Arguments

- base_url:

  Base URL of the CHELSA repository. Defaults to
  "https://os.zhdk.cloud.switch.ch/chelsav2/".

## Value

A tibble with the following columns:

- `url` (character): Full URL of the data file.

- `relative_url` (character): Relative URL, excluding the base URL.

- `file_name` (character): Name of the data file.

- `dir_name` (character): Directory path of the file.

- `climate_scenario` (character): Climate scenario. Values are:
  "current", "ssp126", "ssp370", and "ssp585".

- `climate_model` (character): Climate model. Values are: "Current",
  "GFDL-ESM4", "IPSL-CM6A-LR", "MPI-ESM1-2-HR", "MRI-ESM2-0", and
  "UKESM1-0-LL".

- `year` (character): Year range. Values are "1981-2010", "2011-2040",
  "2041-2070", and "2071-2100".

- `var_name` (character): Variable name, e.g., "bio1".

- `long_name` (character): Full variable name, e.g., "mean annual air
  temperature".

- `unit` (character): Measurement unit, e.g., "°C".

- `scale` (numeric): Scale factor for the variable.

- `offset` (numeric): Offset value for the variable.

- `explanation` (character): Brief description of the variable.

## Author

Ahmed El-Gabbas

## Examples

``` r
library(tibble)
library(dplyr)
library(ecokit)
options(pillar.print_max = 64)

CHELSA_links <- ecokit::get_chelsa_links()

dplyr::glimpse(CHELSA_links)
#> Rows: 2,116
#> Columns: 13
#> $ url              <chr> "https://os.zhdk.cloud.switch.ch/chelsav2/GLOBAL/clim…
#> $ relative_url     <chr> "GLOBAL/climatologies/1981-2010/bio/CHELSA_bio1_1981-…
#> $ file_name        <chr> "CHELSA_bio1_1981-2010_V.2.1.tif", "CHELSA_bio2_1981-…
#> $ dir_name         <chr> "GLOBAL/climatologies/1981-2010/bio", "GLOBAL/climato…
#> $ climate_scenario <chr> "current", "current", "current", "current", "current"…
#> $ climate_model    <chr> "current", "current", "current", "current", "current"…
#> $ year             <chr> "1981-2010", "1981-2010", "1981-2010", "1981-2010", "…
#> $ var_name         <chr> "bio1", "bio2", "bio3", "bio4", "bio5", "bio6", "bio7…
#> $ long_name        <chr> "mean annual air temperature", "mean diurnal air temp…
#> $ unit             <chr> "°C", "°C", "°C", "°C/100", "°C", "°C", "°C", "°C", "…
#> $ scale            <dbl> 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1…
#> $ offset           <dbl> -273.15, 0.00, 0.00, 0.00, -273.15, -273.15, 0.00, -2…
#> $ explanation      <chr> "mean annual daily mean air temperatures averaged ove…

# Count the number of files per climate scenario, model, and year
dplyr::count(CHELSA_links, climate_scenario, climate_model, year)
#> # A tibble: 46 × 4
#>    climate_scenario climate_model year          n
#>    <chr>            <chr>         <chr>     <int>
#>  1 current          current       1981-2010    46
#>  2 ssp126           GFDL-ESM4     2011-2040    46
#>  3 ssp126           GFDL-ESM4     2041-2070    46
#>  4 ssp126           GFDL-ESM4     2071-2100    46
#>  5 ssp126           IPSL-CM6A-LR  2011-2040    46
#>  6 ssp126           IPSL-CM6A-LR  2041-2070    46
#>  7 ssp126           IPSL-CM6A-LR  2071-2100    46
#>  8 ssp126           MPI-ESM1-2-HR 2011-2040    46
#>  9 ssp126           MPI-ESM1-2-HR 2041-2070    46
#> 10 ssp126           MPI-ESM1-2-HR 2071-2100    46
#> 11 ssp126           MRI-ESM2-0    2011-2040    46
#> 12 ssp126           MRI-ESM2-0    2041-2070    46
#> 13 ssp126           MRI-ESM2-0    2071-2100    46
#> 14 ssp126           UKESM1-0-LL   2011-2040    46
#> 15 ssp126           UKESM1-0-LL   2041-2070    46
#> 16 ssp126           UKESM1-0-LL   2071-2100    46
#> 17 ssp370           GFDL-ESM4     2011-2040    46
#> 18 ssp370           GFDL-ESM4     2041-2070    46
#> 19 ssp370           GFDL-ESM4     2071-2100    46
#> 20 ssp370           IPSL-CM6A-LR  2011-2040    46
#> 21 ssp370           IPSL-CM6A-LR  2041-2070    46
#> 22 ssp370           IPSL-CM6A-LR  2071-2100    46
#> 23 ssp370           MPI-ESM1-2-HR 2011-2040    46
#> 24 ssp370           MPI-ESM1-2-HR 2041-2070    46
#> 25 ssp370           MPI-ESM1-2-HR 2071-2100    46
#> 26 ssp370           MRI-ESM2-0    2011-2040    46
#> 27 ssp370           MRI-ESM2-0    2041-2070    46
#> 28 ssp370           MRI-ESM2-0    2071-2100    46
#> 29 ssp370           UKESM1-0-LL   2011-2040    46
#> 30 ssp370           UKESM1-0-LL   2041-2070    46
#> 31 ssp370           UKESM1-0-LL   2071-2100    46
#> 32 ssp585           GFDL-ESM4     2011-2040    46
#> 33 ssp585           GFDL-ESM4     2041-2070    46
#> 34 ssp585           GFDL-ESM4     2071-2100    46
#> 35 ssp585           IPSL-CM6A-LR  2011-2040    46
#> 36 ssp585           IPSL-CM6A-LR  2041-2070    46
#> 37 ssp585           IPSL-CM6A-LR  2071-2100    46
#> 38 ssp585           MPI-ESM1-2-HR 2011-2040    46
#> 39 ssp585           MPI-ESM1-2-HR 2041-2070    46
#> 40 ssp585           MPI-ESM1-2-HR 2071-2100    46
#> 41 ssp585           MRI-ESM2-0    2011-2040    46
#> 42 ssp585           MRI-ESM2-0    2041-2070    46
#> 43 ssp585           MRI-ESM2-0    2071-2100    46
#> 44 ssp585           UKESM1-0-LL   2011-2040    46
#> 45 ssp585           UKESM1-0-LL   2041-2070    46
#> 46 ssp585           UKESM1-0-LL   2071-2100    46

CHELSA_links %>%
  dplyr::count(var_name, long_name, unit, scale, offset, explanation)
#> # A tibble: 46 × 7
#>    var_name long_name                       unit  scale offset explanation     n
#>    <chr>    <chr>                           <chr> <dbl>  <dbl> <chr>       <int>
#>  1 bio1     mean annual air temperature     °C      0.1  -273. "mean annu…    46
#>  2 bio10    mean daily mean air temperatur… °C      0.1  -273. "The warme…    46
#>  3 bio11    mean daily mean air temperatur… °C      0.1  -273. "The colde…    46
#>  4 bio12    annual precipitation amount     kg m…   0.1     0  "Accumulat…    46
#>  5 bio13    precipitation amount of the we… kg m…   0.1     0  "The preci…    46
#>  6 bio14    precipitation amount of the dr… kg m…   0.1     0  "The preci…    46
#>  7 bio15    precipitation seasonality       kg m…   0.1     0  "The Coeff…    46
#>  8 bio16    mean monthly precipitation amo… kg m…   0.1     0  "The wette…    46
#>  9 bio17    mean monthly precipitation amo… kg m…   0.1     0  "The dries…    46
#> 10 bio18    mean monthly precipitation amo… kg m…   0.1     0  "The warme…    46
#> 11 bio19    mean monthly precipitation amo… kg m…   0.1     0  "The colde…    46
#> 12 bio2     mean diurnal air temperature r… °C      0.1     0  "mean diur…    46
#> 13 bio3     isothermality                   °C      0.1     0  "ratio of …    46
#> 14 bio4     temperature seasonality         °C/1…   0.1     0  "standard …    46
#> 15 bio5     mean daily maximum air tempera… °C      0.1  -273. "The highe…    46
#> 16 bio6     mean daily minimum air tempera… °C      0.1  -273. "The lowes…    46
#> 17 bio7     annual range of air temperature °C      0.1     0  "The diffe…    46
#> 18 bio8     mean daily mean air temperatur… °C      0.1  -273. "The wette…    46
#> 19 bio9     mean daily mean air temperatur… °C      0.1  -273. "The dries…    46
#> 20 fcf      Frost change frequency          count  NA      NA  "Number of…    46
#> 21 fgd      first day of the growing seaso… juli…  NA      NA  "first day…    46
#> 22 gdd0     Growing degree days heat sum a… °C      0.1     0  "heat sum …    46
#> 23 gdd10    Growing degree days heat sum a… °C      0.1     0  "heat sum …    46
#> 24 gdd5     Growing degree days heat sum a… °C      0.1     0  "heat sum …    46
#> 25 gddlgd0  Last growing degree day above … juli…  NA      NA  "Last day …    46
#> 26 gddlgd10 Last growing degree day above … juli…  NA      NA  "Last day …    46
#> 27 gddlgd5  Last growing degree day above … juli…  NA      NA  "Last day …    46
#> 28 gdgfgd0  First growing degree day above… juli…  NA      NA  "First day…    46
#> 29 gdgfgd10 First growing degree day above… juli…  NA      NA  "First day…    46
#> 30 gdgfgd5  First growing degree day above… juli…  NA      NA  "First day…    46
#> 31 gsl      growing season length TREELIM   numb…  NA      NA  "Length of…    46
#> 32 gsp      Accumulated precipiation amoun… kg m…   0.1     0  "precipita…    46
#> 33 gst      Mean temperature of the growin… °C      0.1  -273. "Mean temp…    46
#> 34 kg0      Köppen-Geiger climate classifi… cate…  NA      NA  "Köppen Ge…    46
#> 35 kg1      Köppen-Geiger climate classifi… cate…  NA      NA  "Köppen Ge…    46
#> 36 kg2      Köppen-Geiger climate classifi… cate…  NA      NA  "Köppen Ge…    46
#> 37 kg3      Köppen-Geiger climate classifi… cate…  NA      NA  "Wissmann …    46
#> 38 kg4      Köppen-Geiger climate classifi… cate…  NA      NA  "Thornthwa…    46
#> 39 kg5      Köppen-Geiger climate classifi… cate…  NA      NA  "Troll-Pfa…    46
#> 40 lgd      last day of the growing season… juli…  NA      NA  "Last day …    46
#> 41 ngd0     Number of growing degree days   numb…  NA      NA  "Number of…    46
#> 42 ngd10    Number of growing degree days   numb…  NA      NA  "Number of…    46
#> 43 ngd5     Number of growing degree days   numb…  NA      NA  "Number of…    46
#> 44 npp      Net primary productivity        g C …   0.1     0  "Calculate…    46
#> 45 scd      Snow cover days                 count  NA      NA  "Number of…    46
#> 46 swe      Snow water equivalent           kg m…   0.1     0  "Amount of…    46

ecokit::ht(CHELSA_links)
#>                                                                                                                                                      url
#>                                                                                                                                                   <char>
#>    1:                                        https://os.zhdk.cloud.switch.ch/chelsav2/GLOBAL/climatologies/1981-2010/bio/CHELSA_bio1_1981-2010_V.2.1.tif
#>    2:                                        https://os.zhdk.cloud.switch.ch/chelsav2/GLOBAL/climatologies/1981-2010/bio/CHELSA_bio2_1981-2010_V.2.1.tif
#>    3:                                        https://os.zhdk.cloud.switch.ch/chelsav2/GLOBAL/climatologies/1981-2010/bio/CHELSA_bio3_1981-2010_V.2.1.tif
#>    4:                                        https://os.zhdk.cloud.switch.ch/chelsav2/GLOBAL/climatologies/1981-2010/bio/CHELSA_bio4_1981-2010_V.2.1.tif
#>    5:                                        https://os.zhdk.cloud.switch.ch/chelsav2/GLOBAL/climatologies/1981-2010/bio/CHELSA_bio5_1981-2010_V.2.1.tif
#>   ---                                                                                                                                                   
#> 2112:  https://os.zhdk.cloud.switch.ch/chelsav2/GLOBAL/climatologies/2071-2100/UKESM1-0-LL/ssp585/bio/CHELSA_ngd5_2071-2100_ukesm1-0-ll_ssp585_V.2.1.tif
#> 2113: https://os.zhdk.cloud.switch.ch/chelsav2/GLOBAL/climatologies/2071-2100/UKESM1-0-LL/ssp585/bio/CHELSA_ngd10_2071-2100_ukesm1-0-ll_ssp585_V.2.1.tif
#> 2114:   https://os.zhdk.cloud.switch.ch/chelsav2/GLOBAL/climatologies/2071-2100/UKESM1-0-LL/ssp585/bio/CHELSA_npp_2071-2100_ukesm1-0-ll_ssp585_V.2.1.tif
#> 2115:   https://os.zhdk.cloud.switch.ch/chelsav2/GLOBAL/climatologies/2071-2100/UKESM1-0-LL/ssp585/bio/CHELSA_scd_2071-2100_ukesm1-0-ll_ssp585_V.2.1.tif
#> 2116:   https://os.zhdk.cloud.switch.ch/chelsav2/GLOBAL/climatologies/2071-2100/UKESM1-0-LL/ssp585/bio/CHELSA_swe_2071-2100_ukesm1-0-ll_ssp585_V.2.1.tif
#>                                                                                                    relative_url
#>                                                                                                          <char>
#>    1:                                        GLOBAL/climatologies/1981-2010/bio/CHELSA_bio1_1981-2010_V.2.1.tif
#>    2:                                        GLOBAL/climatologies/1981-2010/bio/CHELSA_bio2_1981-2010_V.2.1.tif
#>    3:                                        GLOBAL/climatologies/1981-2010/bio/CHELSA_bio3_1981-2010_V.2.1.tif
#>    4:                                        GLOBAL/climatologies/1981-2010/bio/CHELSA_bio4_1981-2010_V.2.1.tif
#>    5:                                        GLOBAL/climatologies/1981-2010/bio/CHELSA_bio5_1981-2010_V.2.1.tif
#>   ---                                                                                                          
#> 2112:  GLOBAL/climatologies/2071-2100/UKESM1-0-LL/ssp585/bio/CHELSA_ngd5_2071-2100_ukesm1-0-ll_ssp585_V.2.1.tif
#> 2113: GLOBAL/climatologies/2071-2100/UKESM1-0-LL/ssp585/bio/CHELSA_ngd10_2071-2100_ukesm1-0-ll_ssp585_V.2.1.tif
#> 2114:   GLOBAL/climatologies/2071-2100/UKESM1-0-LL/ssp585/bio/CHELSA_npp_2071-2100_ukesm1-0-ll_ssp585_V.2.1.tif
#> 2115:   GLOBAL/climatologies/2071-2100/UKESM1-0-LL/ssp585/bio/CHELSA_scd_2071-2100_ukesm1-0-ll_ssp585_V.2.1.tif
#> 2116:   GLOBAL/climatologies/2071-2100/UKESM1-0-LL/ssp585/bio/CHELSA_swe_2071-2100_ukesm1-0-ll_ssp585_V.2.1.tif
#>                                                 file_name
#>                                                    <char>
#>    1:                     CHELSA_bio1_1981-2010_V.2.1.tif
#>    2:                     CHELSA_bio2_1981-2010_V.2.1.tif
#>    3:                     CHELSA_bio3_1981-2010_V.2.1.tif
#>    4:                     CHELSA_bio4_1981-2010_V.2.1.tif
#>    5:                     CHELSA_bio5_1981-2010_V.2.1.tif
#>   ---                                                    
#> 2112:  CHELSA_ngd5_2071-2100_ukesm1-0-ll_ssp585_V.2.1.tif
#> 2113: CHELSA_ngd10_2071-2100_ukesm1-0-ll_ssp585_V.2.1.tif
#> 2114:   CHELSA_npp_2071-2100_ukesm1-0-ll_ssp585_V.2.1.tif
#> 2115:   CHELSA_scd_2071-2100_ukesm1-0-ll_ssp585_V.2.1.tif
#> 2116:   CHELSA_swe_2071-2100_ukesm1-0-ll_ssp585_V.2.1.tif
#>                                                    dir_name climate_scenario
#>                                                      <char>           <char>
#>    1:                    GLOBAL/climatologies/1981-2010/bio          current
#>    2:                    GLOBAL/climatologies/1981-2010/bio          current
#>    3:                    GLOBAL/climatologies/1981-2010/bio          current
#>    4:                    GLOBAL/climatologies/1981-2010/bio          current
#>    5:                    GLOBAL/climatologies/1981-2010/bio          current
#>   ---                                                                       
#> 2112: GLOBAL/climatologies/2071-2100/UKESM1-0-LL/ssp585/bio           ssp585
#> 2113: GLOBAL/climatologies/2071-2100/UKESM1-0-LL/ssp585/bio           ssp585
#> 2114: GLOBAL/climatologies/2071-2100/UKESM1-0-LL/ssp585/bio           ssp585
#> 2115: GLOBAL/climatologies/2071-2100/UKESM1-0-LL/ssp585/bio           ssp585
#> 2116: GLOBAL/climatologies/2071-2100/UKESM1-0-LL/ssp585/bio           ssp585
#>       climate_model      year var_name
#>              <char>    <char>   <char>
#>    1:       current 1981-2010     bio1
#>    2:       current 1981-2010     bio2
#>    3:       current 1981-2010     bio3
#>    4:       current 1981-2010     bio4
#>    5:       current 1981-2010     bio5
#>   ---                                 
#> 2112:   UKESM1-0-LL 2071-2100     ngd5
#> 2113:   UKESM1-0-LL 2071-2100    ngd10
#> 2114:   UKESM1-0-LL 2071-2100      npp
#> 2115:   UKESM1-0-LL 2071-2100      scd
#> 2116:   UKESM1-0-LL 2071-2100      swe
#>                                                     long_name           unit
#>                                                        <char>         <char>
#>    1:                             mean annual air temperature             °C
#>    2:                      mean diurnal air temperature range             °C
#>    3:                                           isothermality             °C
#>    4:                                 temperature seasonality         °C/100
#>    5: mean daily maximum air temperature of the warmest month             °C
#>   ---                                                                       
#> 2112:                           Number of growing degree days number of days
#> 2113:                           Number of growing degree days number of days
#> 2114:                                Net primary productivity   g C m−2 yr−1
#> 2115:                                         Snow cover days          count
#> 2116:                                   Snow water equivalent  kg m-2 year-1
#>       scale  offset
#>       <num>   <num>
#>    1:   0.1 -273.15
#>    2:   0.1    0.00
#>    3:   0.1    0.00
#>    4:   0.1    0.00
#>    5:   0.1 -273.15
#>   ---              
#> 2112:    NA      NA
#> 2113:    NA      NA
#> 2114:   0.1    0.00
#> 2115:    NA      NA
#> 2116:   0.1    0.00
#>                                                                                                                                                  explanation
#>                                                                                                                                                       <char>
#>    1:                                                                                           mean annual daily mean air temperatures averaged over 1 year
#>    2:                                                                                                mean diurnal range of temperatures averaged over 1 year
#>    3:                                                                                         ratio of diurnal variation to annual variation in temperatures
#>    4:                                                                                                    standard deviation of the monthly mean temperatures
#>    5:                                                                                  The highest temperature of any monthly daily mean maximum temperature
#>   ---                                                                                                                                                       
#> 2112:                                                                                                                      Number of days at which tas > 5°C
#> 2113:                                                                                                                     Number of days at which tas > 10°C
#> 2114: Calculated based on the ‘Miami model’, Lieth, H., 1972. "Modelling the primary productivity of the earth. Nature and resources", UNESCO, VIII, 2:5-10.
#> 2115:            Number of days with snowcover calculated using the snowpack model implementation in from TREELIM (https://doi.org/10.1007/s00035-0140124-0)
#> 2116:                                                                                                               Amount of liquid water if snow is melted
```
