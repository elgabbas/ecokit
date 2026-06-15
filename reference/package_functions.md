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
#>  [57] "get_group_descendants"      "get_mode"                  
#>  [59] "get_option_with_default"    "get_sampling_effort"       
#>  [61] "git_log"                    "ht"                        
#>  [63] "info_chunk"                 "integer_breaks"            
#>  [65] "is_integer"                 "keep_only"                 
#>  [67] "lapply_"                    "list_to_rdata"             
#>  [69] "load_as"                    "load_multiple"             
#>  [71] "load_packages"              "load_packages_future"      
#>  [73] "load_tar_file"              "loaded_packages"           
#>  [75] "mask_cumulative_pct"        "maxent_open"               
#>  [77] "maxent_variable_importance" "n_decimals"                
#>  [79] "n_unique"                   "nc_global_attributes"      
#>  [81] "nearest_dist_sf"            "normalize_path"            
#>  [83] "os"                         "package_functions"         
#>  [85] "package_installed"          "package_remote_sha"        
#>  [87] "pak_from_renv"              "parent_dir"                
#>  [89] "polygon_centroid"           "quiet_device"              
#>  [91] "quietly"                    "range_to_new_value"        
#>  [93] "raster_dims_km"             "raster_to_pres_abs"        
#>  [95] "record_arguments"           "reload_package"            
#>  [97] "remove_options"             "rename_geometry"           
#>  [99] "render_html"                "replace_space"             
#> [101] "sapply_"                    "save_as"                   
#> [103] "save_multiple"              "save_session"              
#> [105] "save_session_info"          "scale_0_1"                 
#> [107] "scrape_link"                "script_location"           
#> [109] "set_geometry"               "set_parallel"              
#> [111] "set_raster_crs"             "set_raster_varnames"       
#> [113] "sf_add_coords"              "sort_raster_layers"        
#> [115] "source_silent"              "split_df_to_chunks"        
#> [117] "split_raster"               "split_vector"              
#> [119] "stop_ctx"                   "system_command"            
#> [121] "text_to_coordinates"        "tibble_column_size"        
#> [123] "trim_hmsc"                  "used_packages"             
#> [125] "validate_n_cores"           "validate_named_list"       
#> [127] "validate_slurm_ram"         "validate_slurm_runtime"    
#> [129] "validate_strategy"          "write_nc"                  
#> [131] "zenodo_download_file"       "zenodo_file_list"          

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
