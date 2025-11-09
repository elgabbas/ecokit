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
#>  chr [1:156] "%>%" "FULL_bbox_" "NA_agr_" "NA_bbox_" "NA_crs_" ...

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
#>  [25] "check_image"                "check_packages"            
#>  [27] "check_qs"                   "check_quarto"              
#>  [29] "check_rdata"                "check_rds"                 
#>  [31] "check_rstudio"              "check_stack_in_memory"     
#>  [33] "check_system_command"       "check_tiff"                
#>  [35] "check_url"                  "check_zip"                 
#>  [37] "chelsa_var_info"            "clear_console"             
#>  [39] "clip_raster_by_polygon"     "detect_alias"              
#>  [41] "dir_size"                   "extract_options"           
#>  [43] "file_extension"             "file_size"                 
#>  [45] "file_type"                  "find_duplicates"           
#>  [47] "format_number"              "function_arguments"        
#>  [49] "get_chelsa_links"           "get_mode"                  
#>  [51] "get_option_with_default"    "git_log"                   
#>  [53] "ht"                         "info_chunk"                
#>  [55] "integer_breaks"             "keep_only"                 
#>  [57] "lapply_"                    "list_to_rdata"             
#>  [59] "load_as"                    "load_multiple"             
#>  [61] "load_packages"              "load_packages_future"      
#>  [63] "load_tar_file"              "loaded_packages"           
#>  [65] "maxent_open"                "maxent_variable_importance"
#>  [67] "n_decimals"                 "n_unique"                  
#>  [69] "nc_global_attributes"       "nearest_dist_sf"           
#>  [71] "normalize_path"             "os"                        
#>  [73] "package_functions"          "package_remote_sha"        
#>  [75] "pak_from_renv"              "parent_dir"                
#>  [77] "polygon_centroid"           "quiet_device"              
#>  [79] "quietly"                    "range_to_new_value"        
#>  [81] "raster_to_pres_abs"         "record_arguments"          
#>  [83] "reload_package"             "remove_options"            
#>  [85] "rename_geometry"            "replace_space"             
#>  [87] "sapply_"                    "save_as"                   
#>  [89] "save_multiple"              "save_session"              
#>  [91] "save_session_info"          "scale_0_1"                 
#>  [93] "scrape_link"                "script_location"           
#>  [95] "set_geometry"               "set_parallel"              
#>  [97] "set_raster_crs"             "sf_add_coords"             
#>  [99] "source_silent"              "split_df_to_chunks"        
#> [101] "split_raster"               "split_vector"              
#> [103] "stop_ctx"                   "system_command"            
#> [105] "text_to_coordinates"        "tibble_column_size"        
#> [107] "used_packages"              "write_nc"                  
#> [109] "zenodo_download_file"       "zenodo_file_list"          

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
