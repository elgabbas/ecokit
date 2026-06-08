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
#>  [39] "clip_raster_by_polygon"     "create_tar"                
#>  [41] "detect_alias"               "detect_outliers"           
#>  [43] "dir_size"                   "extract_options"           
#>  [45] "file_extension"             "file_size"                 
#>  [47] "file_type"                  "find_duplicates"           
#>  [49] "format_number"              "function_arguments"        
#>  [51] "get_chelsa_links"           "get_group_descendants"     
#>  [53] "get_mode"                   "get_option_with_default"   
#>  [55] "get_sampling_effort"        "git_log"                   
#>  [57] "ht"                         "info_chunk"                
#>  [59] "integer_breaks"             "keep_only"                 
#>  [61] "lapply_"                    "list_to_rdata"             
#>  [63] "load_as"                    "load_multiple"             
#>  [65] "load_packages"              "load_packages_future"      
#>  [67] "load_tar_file"              "loaded_packages"           
#>  [69] "mask_cumulative_pct"        "maxent_open"               
#>  [71] "maxent_variable_importance" "n_decimals"                
#>  [73] "n_unique"                   "nc_global_attributes"      
#>  [75] "nearest_dist_sf"            "normalize_path"            
#>  [77] "os"                         "package_functions"         
#>  [79] "package_remote_sha"         "pak_from_renv"             
#>  [81] "parent_dir"                 "polygon_centroid"          
#>  [83] "quiet_device"               "quietly"                   
#>  [85] "range_to_new_value"         "raster_dims_km"            
#>  [87] "raster_to_pres_abs"         "record_arguments"          
#>  [89] "reload_package"             "remove_options"            
#>  [91] "rename_geometry"            "replace_space"             
#>  [93] "sapply_"                    "save_as"                   
#>  [95] "save_multiple"              "save_session"              
#>  [97] "save_session_info"          "scale_0_1"                 
#>  [99] "scrape_link"                "script_location"           
#> [101] "set_geometry"               "set_parallel"              
#> [103] "set_raster_crs"             "set_raster_varnames"       
#> [105] "sf_add_coords"              "sort_raster_layers"        
#> [107] "source_silent"              "split_df_to_chunks"        
#> [109] "split_raster"               "split_vector"              
#> [111] "stop_ctx"                   "system_command"            
#> [113] "text_to_coordinates"        "tibble_column_size"        
#> [115] "used_packages"              "write_nc"                  
#> [117] "zenodo_download_file"       "zenodo_file_list"          

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
