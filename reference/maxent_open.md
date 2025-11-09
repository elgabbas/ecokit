# Launch the Maxent Java Application from the dismo Package

This function locates and launches the Maxent Java application
(`maxent.jar`) that is distributed with the `dismo` R package. It
performs robust checks for required package installations, the presence
of Java, and the availability of the JAR file. If all checks pass, it
attempts to launch the Maxent graphical user interface using your
system's Java installation.

## Usage

``` r
maxent_open()
```

## Value

Invisibly returns the result of the system call (integer exit status on
most platforms). Stops with an informative error if unsuccessful.

## Details

**Note:** This function works on Windows, macOS, and Linux, provided
that Java is correctly installed and available on your system PATH. The
function does not attempt to modify any system configurations. For
headless (server) environments, the GUI may not be displayed.

Maxent is a Java-based application for species distribution modelling.
The `dismo` package bundles the Maxent JAR file and provides R wrappers
for interacting with it. This function is a convenience to open the
Maxent GUI from within R.

If Java is not installed or not found on your PATH, or if Maxent is
missing from the expected location, informative errors will be given.
The function returns (invisibly) the result from the system call to
launch Maxent.

## Author

Ahmed El-Gabbas

## Examples

``` r
if (FALSE) { # \dontrun{
  require(ecokit)
  ecokit::load_packages(dismo, rJava)

  # Launch Maxent GUI from the dismo package
  maxent_open()
} # }
```
