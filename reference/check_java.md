# Check that Java is available on the system PATH

Verifies that a `java` executable can be located and invoked from the
system shell, by running `java -version` and checking both that the call
succeeds and that it returns a zero exit status.

## Usage

``` r
check_java()
```

## Value

Invisibly returns `TRUE` if Java is available and callable; otherwise
throws an error, including the captured command output and exit status
(if any) for debugging.

## Author

Ahmed El-Gabbas

## Examples

``` r
if (FALSE) { # \dontrun{
  check_java()
} # }
```
