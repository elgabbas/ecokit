# Extracts link texts and URLs from a web page

This function scrapes a web page for all links (`<a>` tags) and extracts
both the URLs and the link text.

## Usage

``` r
scrape_link(url, sort_by = c("link", "link_text"))
```

## Arguments

- url:

  Character. The URL of the web page to scrape. This URL is also used to
  resolve relative links to absolute URLs if no `<base>` tag is found.

- sort_by:

  Character vector of length 1 or 2. The columns to arrange the output
  by. The default is c("link", "link_text").

## Value

A tibble with two columns: `link_text` containing the text of each link,
and `link` containing the absolute URL of each link. The tibble is
sorted by link and then by link text, and only unique links are
included.

## Examples

``` r
head(scrape_link(url = "https://github.com/tidyverse/dplyr"))
#> # A tibble: 6 × 2
#>   link_text       link                                                      
#>   <chr>           <chr>                                                     
#> 1 Archive Program https://archiveprogram.github.com                         
#> 2 Acero           https://arrow.apache.org/docs/cpp/streaming_execution.html
#> 3 arrow           https://arrow.apache.org/docs/r/                          
#> 4 dbplyr          https://dbplyr.tidyverse.org/                             
#> 5 Documentation   https://docs.github.com                                   
#> 6 Docs            https://docs.github.com/                                  

head(
  scrape_link(
    url = "https://github.com/tidyverse/dplyr", sort_by = "link_text"))
#> # A tibble: 6 × 2
#>   link_text          link                                                      
#>   <chr>              <chr>                                                     
#> 1 + 266 contributors https://github.com/tidyverse/dplyr/graphs/contributors    
#> 2 + 42 releases      https://github.com/tidyverse/dplyr/releases               
#> 3 .Rbuildignore      https://github.com/tidyverse/dplyr/blob/main/.Rbuildignore
#> 4 .github            https://github.com/tidyverse/dplyr/tree/main/.github      
#> 5 .gitignore         https://github.com/tidyverse/dplyr/blob/main/.gitignore   
#> 6 .vscode            https://github.com/tidyverse/dplyr/tree/main/.vscode      

# This will give an "Invalid url" error
try(scrape_link(url = "https://github50.com"))
#> Error in scrape_link(url = "https://github50.com") : 
#>   Invalid url
#> 
#> ----- Metadata -----
#> 
#> url [url]: <character>
#> https://github50.com
```
