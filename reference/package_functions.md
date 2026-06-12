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
#>  [41] "clip_raster_by_polygon"     "create_tar"                
#>  [43] "detect_alias"               "detect_outliers"           
#>  [45] "dir_size"                   "extract_options"           
#>  [47] "file_extension"             "file_size"                 
#>  [49] "file_type"                  "find_capital_names"        
#>  [51] "find_duplicates"            "format_number"             
#>  [53] "function_arguments"         "get_chelsa_links"          
#>  [55] "get_group_descendants"      "get_mode"                  
#>  [57] "get_option_with_default"    "get_sampling_effort"       
#>  [59] "git_log"                    "ht"                        
#>  [61] "info_chunk"                 "integer_breaks"            
#>  [63] "is_integer"                 "keep_only"                 
#>  [65] "lapply_"                    "list_to_rdata"             
#>  [67] "load_as"                    "load_multiple"             
#>  [69] "load_packages"              "load_packages_future"      
#>  [71] "load_tar_file"              "loaded_packages"           
#>  [73] "mask_cumulative_pct"        "maxent_open"               
#>  [75] "maxent_variable_importance" "n_decimals"                
#>  [77] "n_unique"                   "nc_global_attributes"      
#>  [79] "nearest_dist_sf"            "normalize_path"            
#>  [81] "os"                         "package_functions"         
#>  [83] "package_installed"          "package_remote_sha"        
#>  [85] "pak_from_renv"              "parent_dir"                
#>  [87] "polygon_centroid"           "quiet_device"              
#>  [89] "quietly"                    "range_to_new_value"        
#>  [91] "raster_dims_km"             "raster_to_pres_abs"        
#>  [93] "record_arguments"           "reload_package"            
#>  [95] "remove_options"             "rename_geometry"           
#>  [97] "render_html"                "replace_space"             
#>  [99] "sapply_"                    "save_as"                   
#> [101] "save_multiple"              "save_session"              
#> [103] "save_session_info"          "scale_0_1"                 
#> [105] "scrape_link"                "script_location"           
#> [107] "set_geometry"               "set_parallel"              
#> [109] "set_raster_crs"             "set_raster_varnames"       
#> [111] "sf_add_coords"              "sort_raster_layers"        
#> [113] "source_silent"              "split_df_to_chunks"        
#> [115] "split_raster"               "split_vector"              
#> [117] "stop_ctx"                   "system_command"            
#> [119] "text_to_coordinates"        "tibble_column_size"        
#> [121] "used_packages"              "validate_n_cores"          
#> [123] "validate_named_list"        "validate_slurm_ram"        
#> [125] "validate_slurm_runtime"     "validate_strategy"         
#> [127] "write_nc"                   "zenodo_download_file"      
#> [129] "zenodo_file_list"          

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
