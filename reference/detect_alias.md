# Detect aliased variables in a linear model

This function identifies aliased (linearly dependent) variables in a
linear model by fitting a linear model, and then using the
[stats::alias](https://rdrr.io/r/stats/alias.html) function to detect
aliased variables.

## Usage

``` r
detect_alias(data, verbose = FALSE)
```

## Arguments

- data:

  A `data frame` or `tibble` containing the variables to be checked for
  aliasing.

- verbose:

  Logical. Whether to print the aliased variables found (if any). If
  `TRUE`, aliased variables are printed to the console. Defaults to
  `FALSE`.

## Value

Returns a character vector of aliased variable names if any are found;
otherwise, returns `NULL` invisibly. If `verbose` is `TRUE`, the
function will also print a message to the console.

## Author

Ahmed El-Gabbas

## Examples

``` r
load_packages(car)

x1 <- rnorm(100)
x2 <- 2 * x1
x3 <- rnorm(100)
y <- rnorm(100)

model <- lm(y ~ x1 + x2 + x3)
summary(model)
#> 
#> Call:
#> lm(formula = y ~ x1 + x2 + x3)
#> 
#> Residuals:
#>      Min       1Q   Median       3Q      Max 
#> -2.41023 -0.65355  0.00811  0.56445  2.64364 
#> 
#> Coefficients: (1 not defined because of singularities)
#>             Estimate Std. Error t value Pr(>|t|)
#> (Intercept) -0.10923    0.09999  -1.092    0.277
#> x1          -0.03670    0.10457  -0.351    0.726
#> x2                NA         NA      NA       NA
#> x3           0.11295    0.11621   0.972    0.334
#> 
#> Residual standard error: 0.9926 on 97 degrees of freedom
#> Multiple R-squared:  0.01032,    Adjusted R-squared:  -0.01008 
#> F-statistic: 0.5059 on 2 and 97 DF,  p-value: 0.6045
#> 

# there are aliased coefficients in the model
try(car::vif(model))
#> Error in vif.default(model) : there are aliased coefficients in the model

# The function identifies the aliased variables
detect_alias(data = cbind.data.frame(x1, x2, x3))
#> [1] "x2"

detect_alias(data = cbind.data.frame(x1, x2, x3), verbose = TRUE)
#> aliased variables: x2
#> [1] "x2"

# excluding x2 and refit the model
model <- lm(y ~ x1 + x3)

summary(model)
#> 
#> Call:
#> lm(formula = y ~ x1 + x3)
#> 
#> Residuals:
#>      Min       1Q   Median       3Q      Max 
#> -2.41023 -0.65355  0.00811  0.56445  2.64364 
#> 
#> Coefficients:
#>             Estimate Std. Error t value Pr(>|t|)
#> (Intercept) -0.10923    0.09999  -1.092    0.277
#> x1          -0.03670    0.10457  -0.351    0.726
#> x3           0.11295    0.11621   0.972    0.334
#> 
#> Residual standard error: 0.9926 on 97 degrees of freedom
#> Multiple R-squared:  0.01032,    Adjusted R-squared:  -0.01008 
#> F-statistic: 0.5059 on 2 and 97 DF,  p-value: 0.6045
#> 

try(car::vif(model))
#>       x1       x3 
#> 1.009248 1.009248 
```
