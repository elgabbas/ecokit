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
#>  [27] "check_pdf"                  "check_qs"                  
#>  [29] "check_quarto"               "check_rdata"               
#>  [31] "check_rds"                  "check_rstudio"             
#>  [33] "check_stack_in_memory"      "check_system_command"      
#>  [35] "check_tiff"                 "check_url"                 
#>  [37] "check_zip"                  "chelsa_var_info"           
#>  [39] "clear_console"              "clip_raster_by_polygon"    
#>  [41] "create_tar"                 "detect_alias"              
#>  [43] "detect_outliers"            "dir_size"                  
#>  [45] "extract_options"            "file_extension"            
#>  [47] "file_size"                  "file_type"                 
#>  [49] "find_duplicates"            "format_number"             
#>  [51] "function_arguments"         "get_chelsa_links"          
#>  [53] "get_group_descendants"      "get_mode"                  
#>  [55] "get_option_with_default"    "get_sampling_effort"       
#>  [57] "git_log"                    "ht"                        
#>  [59] "info_chunk"                 "integer_breaks"            
#>  [61] "keep_only"                  "lapply_"                   
#>  [63] "list_to_rdata"              "load_as"                   
#>  [65] "load_multiple"              "load_packages"             
#>  [67] "load_packages_future"       "load_tar_file"             
#>  [69] "loaded_packages"            "mask_cumulative_pct"       
#>  [71] "maxent_open"                "maxent_variable_importance"
#>  [73] "n_decimals"                 "n_unique"                  
#>  [75] "nc_global_attributes"       "nearest_dist_sf"           
#>  [77] "normalize_path"             "os"                        
#>  [79] "package_functions"          "package_installed"         
#>  [81] "package_remote_sha"         "pak_from_renv"             
#>  [83] "parent_dir"                 "polygon_centroid"          
#>  [85] "quiet_device"               "quietly"                   
#>  [87] "range_to_new_value"         "raster_dims_km"            
#>  [89] "raster_to_pres_abs"         "record_arguments"          
#>  [91] "reload_package"             "remove_options"            
#>  [93] "rename_geometry"            "replace_space"             
#>  [95] "sapply_"                    "save_as"                   
#>  [97] "save_multiple"              "save_session"              
#>  [99] "save_session_info"          "scale_0_1"                 
#> [101] "scrape_link"                "script_location"           
#> [103] "set_geometry"               "set_parallel"              
#> [105] "set_raster_crs"             "set_raster_varnames"       
#> [107] "sf_add_coords"              "sort_raster_layers"        
#> [109] "source_silent"              "split_df_to_chunks"        
#> [111] "split_raster"               "split_vector"              
#> [113] "stop_ctx"                   "system_command"            
#> [115] "text_to_coordinates"        "tibble_column_size"        
#> [117] "used_packages"              "write_nc"                  
#> [119] "zenodo_download_file"       "zenodo_file_list"          

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
