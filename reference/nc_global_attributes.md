# Get global attributes for `NetCDF` files

This function opens a `NetCDF` file, extracts all global attributes, and
returns them as a character vector where each element is an attribute
name-value pair.

## Usage

``` r
nc_global_attributes(nc = NULL)
```

## Arguments

- nc:

  Character. Path to the `NetCDF` file. If `NULL`, the function will
  stop with an error message.

## Value

A character vector where each element is a global attribute.

## References

[Click here](https://github.com/rspatial/terra/issues/1443)

## Examples

``` r
require(ecokit)
ecokit::load_packages(sf, fs)

nc_example_3 <- system.file("nc/cropped.nc", package = "sf")
if (fs::file_exists(nc_example_3)) nc_global_attributes(nc = nc_example_3)
#> [1] "Conventions=CF-1.0"                                                                                                           
#> [2] "title=Daily-OI-V2, final, Data (Ship, Buoy, AVHRR, GSFC-ice)"                                                                 
#> [3] "History=Tue Feb 13 20:40:49 2018: ncks -d lat,30,40 -d lon,25,50 avhrr-only-v2.19810901.nc -O cropped_example.nc\nVersion 2.0"
#> [4] "creation_date=2011-05-04"                                                                                                     
#> [5] "Source=NOAA/National Climatic Data Center"                                                                                    
#> [6] "Contact=Dick Reynolds, email: Richard.W.Reynolds@noaa.gov & Chunying Liu, email: Chunying.liu@noaa.gov"                       
#> [7] "NCO=4.6.8"                                                                                                                    
```
