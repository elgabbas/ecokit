# List of functions in a package

This function returns a character vector listing all the functions
available in the specified R package. It first checks if the package is
installed and can be loaded; if not, it raises an error.

## Usage

``` r
package_functions(package)
```

## Arguments

- package:

  Character. Package name.

## Value

A character vector containing the names of all functions in the
specified package.

## Author

Ahmed El-Gabbas

## Examples

``` r
str(package_functions(package = "raster"))
#>  chr [1:281] "%in%" "Arith" "Compare" "Geary" "GearyLocal" "KML" "Logic" ...

str(package_functions(package = "sf"))
#>  chr [1:154] "FULL_bbox_" "NA_agr_" "NA_bbox_" "NA_crs_" "NA_m_range_" ...

package_functions(package = "ecokit")
#>   [1] "%>%"                        "add_cross_to_grid"         
#>   [3] "add_diagonals_to_grid"      "add_image_to_plot"         
#>   [5] "add_line"                   "add_missing_columns"       
#>   [7] "all_objects_sizes"          "arrange_alphanum"          
#>   [9] "assign_env_vars"            "assign_from_options"       
#>  [11] "assign_if_not_exist"        "bash_variables"            
#>  [13] "binned_heatmap"             "boundary_to_wkt"           
#>  [15] "cat_diff"                   "cat_names"                 
#>  [17] "cat_sep"                    "cat_time"                  
#>  [19] "cc"                         "check_args"                
#>  [21] "check_data"                 "check_env_file"            
#>  [23] "check_feather"              "check_gbif"                
#>  [25] "check_image"                "check_java"                
#>  [27] "check_packages"             "check_pdf"                 
#>  [29] "check_qs"                   "check_quarto"              
#>  [31] "check_rdata"                "check_rds"                 
#>  [33] "check_rstudio"              "check_stack_in_memory"     
#>  [35] "check_system_command"       "check_tiff"                
#>  [37] "check_url"                  "check_zip"                 
#>  [39] "chelsa_var_info"            "clear_console"             
#>  [41] "clip_raster_by_polygon"     "coda_match_param"          
#>  [43] "coda_to_tibble"             "create_tar"                
#>  [45] "detect_alias"               "detect_outliers"           
#>  [47] "dir_size"                   "extract_options"           
#>  [49] "file_extension"             "file_size"                 
#>  [51] "file_type"                  "find_capital_names"        
#>  [53] "find_duplicates"            "format_number"             
#>  [55] "function_arguments"         "get_chelsa_links"          
#>  [57] "get_group_descendants"      "get_inat_obs"              
#>  [59] "get_mode"                   "get_option_with_default"   
#>  [61] "get_sampling_effort"        "git_log"                   
#>  [63] "ht"                         "info_chunk"                
#>  [65] "integer_breaks"             "is_integer"                
#>  [67] "keep_only"                  "lapply_"                   
#>  [69] "list_to_rdata"              "load_as"                   
#>  [71] "load_multiple"              "load_packages"             
#>  [73] "load_packages_future"       "load_tar_file"             
#>  [75] "loaded_packages"            "mask_cumulative_pct"       
#>  [77] "maxent_open"                "maxent_variable_importance"
#>  [79] "n_decimals"                 "n_unique"                  
#>  [81] "nc_global_attributes"       "nearest_dist_sf"           
#>  [83] "normalize_path"             "os"                        
#>  [85] "package_functions"          "package_installed"         
#>  [87] "package_remote_sha"         "pak_from_renv"             
#>  [89] "parent_dir"                 "polygon_centroid"          
#>  [91] "quiet_device"               "quietly"                   
#>  [93] "range_to_new_value"         "raster_dims_km"            
#>  [95] "raster_to_pres_abs"         "record_arguments"          
#>  [97] "reload_package"             "remove_options"            
#>  [99] "rename_geometry"            "render_html"               
#> [101] "replace_space"              "sapply_"                   
#> [103] "save_as"                    "save_multiple"             
#> [105] "save_session"               "save_session_info"         
#> [107] "scale_0_1"                  "scrape_link"               
#> [109] "script_location"            "set_geometry"              
#> [111] "set_parallel"               "set_raster_crs"            
#> [113] "set_raster_varnames"        "sf_add_coords"             
#> [115] "sort_raster_layers"         "source_silent"             
#> [117] "split_df_to_chunks"         "split_raster"              
#> [119] "split_vector"               "stop_ctx"                  
#> [121] "system_command"             "text_to_coordinates"       
#> [123] "tibble_column_size"         "trim_hmsc"                 
#> [125] "used_packages"              "validate_n_cores"          
#> [127] "validate_named_list"        "validate_slurm_ram"        
#> [129] "validate_slurm_runtime"     "validate_strategy"         
#> [131] "write_nc"                   "zenodo_download_file"      
#> [133] "zenodo_file_list"          

# Error: package not found
 try(package_functions(package = "non_exist"))
#> Error in package_functions(package = "non_exist") : 
#>   package not found
#> 
#> ----- Metadata -----
#> 
#> package [package]: <character>
#> non_exist
```
