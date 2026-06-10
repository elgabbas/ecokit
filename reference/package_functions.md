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
#>  [49] "find_capital_names"         "find_duplicates"           
#>  [51] "format_number"              "function_arguments"        
#>  [53] "get_chelsa_links"           "get_group_descendants"     
#>  [55] "get_mode"                   "get_option_with_default"   
#>  [57] "get_sampling_effort"        "git_log"                   
#>  [59] "ht"                         "info_chunk"                
#>  [61] "integer_breaks"             "keep_only"                 
#>  [63] "lapply_"                    "list_to_rdata"             
#>  [65] "load_as"                    "load_multiple"             
#>  [67] "load_packages"              "load_packages_future"      
#>  [69] "load_tar_file"              "loaded_packages"           
#>  [71] "mask_cumulative_pct"        "maxent_open"               
#>  [73] "maxent_variable_importance" "n_decimals"                
#>  [75] "n_unique"                   "nc_global_attributes"      
#>  [77] "nearest_dist_sf"            "normalize_path"            
#>  [79] "os"                         "package_functions"         
#>  [81] "package_installed"          "package_remote_sha"        
#>  [83] "pak_from_renv"              "parent_dir"                
#>  [85] "polygon_centroid"           "quiet_device"              
#>  [87] "quietly"                    "range_to_new_value"        
#>  [89] "raster_dims_km"             "raster_to_pres_abs"        
#>  [91] "record_arguments"           "reload_package"            
#>  [93] "remove_options"             "rename_geometry"           
#>  [95] "render_html"                "replace_space"             
#>  [97] "sapply_"                    "save_as"                   
#>  [99] "save_multiple"              "save_session"              
#> [101] "save_session_info"          "scale_0_1"                 
#> [103] "scrape_link"                "script_location"           
#> [105] "set_geometry"               "set_parallel"              
#> [107] "set_raster_crs"             "set_raster_varnames"       
#> [109] "sf_add_coords"              "sort_raster_layers"        
#> [111] "source_silent"              "split_df_to_chunks"        
#> [113] "split_raster"               "split_vector"              
#> [115] "stop_ctx"                   "system_command"            
#> [117] "text_to_coordinates"        "tibble_column_size"        
#> [119] "used_packages"              "write_nc"                  
#> [121] "zenodo_download_file"       "zenodo_file_list"          

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
