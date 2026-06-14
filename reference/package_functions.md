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
#>  [41] "clip_raster_by_polygon"     "coda_to_tibble"            
#>  [43] "create_tar"                 "detect_alias"              
#>  [45] "detect_outliers"            "dir_size"                  
#>  [47] "extract_options"            "file_extension"            
#>  [49] "file_size"                  "file_type"                 
#>  [51] "find_capital_names"         "find_duplicates"           
#>  [53] "format_number"              "function_arguments"        
#>  [55] "get_chelsa_links"           "get_group_descendants"     
#>  [57] "get_mode"                   "get_option_with_default"   
#>  [59] "get_sampling_effort"        "git_log"                   
#>  [61] "ht"                         "info_chunk"                
#>  [63] "integer_breaks"             "is_integer"                
#>  [65] "keep_only"                  "lapply_"                   
#>  [67] "list_to_rdata"              "load_as"                   
#>  [69] "load_multiple"              "load_packages"             
#>  [71] "load_packages_future"       "load_tar_file"             
#>  [73] "loaded_packages"            "mask_cumulative_pct"       
#>  [75] "maxent_open"                "maxent_variable_importance"
#>  [77] "n_decimals"                 "n_unique"                  
#>  [79] "nc_global_attributes"       "nearest_dist_sf"           
#>  [81] "normalize_path"             "os"                        
#>  [83] "package_functions"          "package_installed"         
#>  [85] "package_remote_sha"         "pak_from_renv"             
#>  [87] "parent_dir"                 "polygon_centroid"          
#>  [89] "quiet_device"               "quietly"                   
#>  [91] "range_to_new_value"         "raster_dims_km"            
#>  [93] "raster_to_pres_abs"         "record_arguments"          
#>  [95] "reload_package"             "remove_options"            
#>  [97] "rename_geometry"            "render_html"               
#>  [99] "replace_space"              "sapply_"                   
#> [101] "save_as"                    "save_multiple"             
#> [103] "save_session"               "save_session_info"         
#> [105] "scale_0_1"                  "scrape_link"               
#> [107] "script_location"            "set_geometry"              
#> [109] "set_parallel"               "set_raster_crs"            
#> [111] "set_raster_varnames"        "sf_add_coords"             
#> [113] "sort_raster_layers"         "source_silent"             
#> [115] "split_df_to_chunks"         "split_raster"              
#> [117] "split_vector"               "stop_ctx"                  
#> [119] "system_command"             "text_to_coordinates"       
#> [121] "tibble_column_size"         "used_packages"             
#> [123] "validate_n_cores"           "validate_named_list"       
#> [125] "validate_slurm_ram"         "validate_slurm_runtime"    
#> [127] "validate_strategy"          "write_nc"                  
#> [129] "zenodo_download_file"       "zenodo_file_list"          

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
