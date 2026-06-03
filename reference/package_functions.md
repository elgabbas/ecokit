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
#>  [25] "check_image"                "check_packages"            
#>  [27] "check_qs"                   "check_quarto"              
#>  [29] "check_rdata"                "check_rds"                 
#>  [31] "check_rstudio"              "check_stack_in_memory"     
#>  [33] "check_system_command"       "check_tiff"                
#>  [35] "check_url"                  "check_zip"                 
#>  [37] "chelsa_var_info"            "clear_console"             
#>  [39] "clip_raster_by_polygon"     "detect_alias"              
#>  [41] "detect_outliers"            "dir_size"                  
#>  [43] "extract_options"            "file_extension"            
#>  [45] "file_size"                  "file_type"                 
#>  [47] "find_duplicates"            "format_number"             
#>  [49] "function_arguments"         "get_chelsa_links"          
#>  [51] "get_group_descendants"      "get_mode"                  
#>  [53] "get_option_with_default"    "get_sampling_effort"       
#>  [55] "git_log"                    "ht"                        
#>  [57] "info_chunk"                 "integer_breaks"            
#>  [59] "keep_only"                  "lapply_"                   
#>  [61] "list_to_rdata"              "load_as"                   
#>  [63] "load_multiple"              "load_packages"             
#>  [65] "load_packages_future"       "load_tar_file"             
#>  [67] "loaded_packages"            "mask_cumulative_pct"       
#>  [69] "maxent_open"                "maxent_variable_importance"
#>  [71] "n_decimals"                 "n_unique"                  
#>  [73] "nc_global_attributes"       "nearest_dist_sf"           
#>  [75] "normalize_path"             "os"                        
#>  [77] "package_functions"          "package_remote_sha"        
#>  [79] "pak_from_renv"              "parent_dir"                
#>  [81] "polygon_centroid"           "quiet_device"              
#>  [83] "quietly"                    "range_to_new_value"        
#>  [85] "raster_dims_km"             "raster_to_pres_abs"        
#>  [87] "record_arguments"           "reload_package"            
#>  [89] "remove_options"             "rename_geometry"           
#>  [91] "replace_space"              "sapply_"                   
#>  [93] "save_as"                    "save_multiple"             
#>  [95] "save_session"               "save_session_info"         
#>  [97] "scale_0_1"                  "scrape_link"               
#>  [99] "script_location"            "set_geometry"              
#> [101] "set_parallel"               "set_raster_crs"            
#> [103] "sf_add_coords"              "sort_raster_layers"        
#> [105] "source_silent"              "split_df_to_chunks"        
#> [107] "split_raster"               "split_vector"              
#> [109] "stop_ctx"                   "system_command"            
#> [111] "text_to_coordinates"        "tibble_column_size"        
#> [113] "used_packages"              "write_nc"                  
#> [115] "zenodo_download_file"       "zenodo_file_list"          

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
