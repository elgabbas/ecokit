#' Plot Binned Heatmap
#'
#' Creates a tile-binned frequency heatmap of two variables using rasterization
#' for efficient handling of large datasets. The function supports `log10`
#' transformations for axes and fill scale, and allows customization of axis
#' labels, title, and subtitle. The function can be useful to visualize the
#' distribution and density of points in a two-dimensional space, especially for
#' large datasets where traditional scatter plots may become cluttered. It can
#' help identify patterns, clusters, and outliers in the data.
#'
#' @param data A data frame containing the variables to plot.
#' @param x,y Character string specifying the column name for the x and y-axis
#'   variables.
#' @param nrow,ncol Integer specifying the number of rows and columns in the
#'   raster grid (default: 100).
#' @param log_x,log_y Logical indicating whether to apply log10 transformation
#'   to x and y axes (default: FALSE).
#' @param log_fill Logical indicating whether to use log10 scale for the fill
#'   (default: FALSE).
#' @param xlab,ylab Character string for the x and y axis label (default:
#'   `NULL`).
#' @param title Character string for the plot title (default: `NULL`).
#' @param subtitle Character string for the plot subtitle (default: `NULL`).
#' @param n_breaks Integer specifying the approximate number of breaks for axes
#'   and colour bar (default: 6).
#' @return A ggplot2 object representing the heatmap.
#'
#' @examples
#'
#' # ------------------------------------------------
#' # Bivariate Normal Data (No Skew)
#' # ------------------------------------------------
#' n <- 10000
#' set.seed(1)
#' df_norm <- data.frame(
#'   x = rnorm(n, mean = 0, sd = 1),
#'   y = rnorm(n, mean = 0, sd = 1))
#' binned_heatmap(df_norm, x = "x", y = "y", title = "Bivariate Normal")
#'
#' # ------------------------------------------------
#' # Strongly Right-Skewed (Log-Normal)
#' # ------------------------------------------------
#' set.seed(2)
#' df_lognorm <- data.frame(
#'   x = rlnorm(n, meanlog = 1, sdlog = 0.6),
#'   y = rlnorm(n, meanlog = 2, sdlog = 1))
#' binned_heatmap(
#'   df_lognorm, x = "x", y = "y",
#'   title = "Bivariate Log-Normal", log_fill = TRUE)
#'
#' # ------------------------------------------------
#' # Left- and Right-Skewed (Beta Shapes)
#' # ------------------------------------------------
#' set.seed(3)
#' df_beta <- data.frame(
#'   x = rbeta(n, shape1 = 2, shape2 = 7), y = rbeta(n, shape1 = 7, shape2 = 2))
#' binned_heatmap(df_beta, x = "x", y = "y", title = "Mixed Skewness (Beta)")
#'
#' # ------------------------------------------------
#' # Strong Bimodal Data
#' # ------------------------------------------------
#' set.seed(4)
#' x_bimodal <- c(rnorm(n / 2, -2), rnorm(n / 2, 3))
#' y_bimodal <- c(rnorm(n / 2, 2),  rnorm(n / 2, -3))
#' df_bimodal <- data.frame(x = x_bimodal, y = y_bimodal)
#' binned_heatmap(df_bimodal, x = "x", y = "y", title = "Bimodal Distribution")
#'
#' # ------------------------------------------------
#' # Clustered Data (Two Clusters, One Skewed)
#' # ------------------------------------------------
#' set.seed(5)
#' n_ct1 <- 6000
#' n_ct2 <- 4000
#' df_clusters <- data.frame(
#'   x = c(rnorm(n_ct1, 2, 0.5), rlnorm(n_ct2, 0.5, 0.8) + 5),
#'   y = c(rnorm(n_ct1, 2, 0.5), rlnorm(n_ct2, 1, 0.8) + 1))
#' binned_heatmap(
#'   df_clusters, x = "x", y = "y",
#'   title = "Clusters: Gaussian & Skewed",
#'   subtitle = "Left = normal, Right = lognormal-skewed")
#'
#' # ------------------------------------------------
#' # Uniform Data (No Skew or Clustering)
#' # ------------------------------------------------
#' set.seed(6)
#' df_uniform <- data.frame(
#'   x = runif(n, min = 0, max = 1), y = runif(n, min = 0, max = 1))
#' binned_heatmap(df_uniform, x = "x", y = "y", title = "Bivariate Uniform")
#'
#' # ------------------------------------------------
#' # Example using dismo bioclimatic variables
#' # ------------------------------------------------
#'
#' # Plotting frequency heatmaps of bioclimatic variables from the dismo package
#' ecokit::load_packages(dplyr, dismo, terra)
#'
#' predictors <- list.files(
#'   path = paste(system.file(package = "dismo"), "/ex", sep = ""),
#'   pattern = "grd", full.names = TRUE) %>%
#'   terra::rast() %>%
#'   as.data.frame(xy = FALSE) %>%
#'   tibble::tibble()
#' head(predictors)
#'
#' binned_heatmap(
#'   predictors, x = "bio1", y = "bio17",
#'   xlab = "Annual Mean Temperature (bio1)",
#'   ylab = "Precipitation of Driest Quarter (bio17)",
#'   title = "Heatmap of Bio1 vs Bio17")
#'
#' binned_heatmap(
#'   predictors, x = "bio12", y = "bio8",
#'   xlab = "Annual Precipitation (bio12)",
#'   ylab = "Mean Temperature of Wettest Quarter (bio8)",
#'   title = "Heatmap of Bio12 vs Bio8")
#'
#' @export
#' @author Ahmed El-Gabbas

binned_heatmap <- function(
    data, x, y, nrow = 100L, ncol = 100L, log_x = FALSE, log_y = FALSE,
    log_fill = FALSE, xlab = NULL, ylab = NULL, title = NULL, subtitle = NULL,
    n_breaks = 6L) {

  plot_x <- plot_y <- NULL

  # Set terra options for memory management
  terra::terraOptions(memfrac = 0.05, todisk = TRUE, memmax = 1e5L)

  # Filter out NA values in x and y
  data <- data %>%
    dplyr::filter(!is.na(.data[[x]]), !is.na(.data[[y]]))

  # Check for positive values if log transformation is requested
  if (log_x && min(data[[x]]) <= 0L) {
    ecokit::stop_ctx("Cannot apply log10 to x: values must be positive.")
  }
  if (log_y && min(data[[y]]) <= 0L) {
    ecokit::stop_ctx("Cannot apply log10 to y: values must be positive.")
  }

  # Transform variables for plotting (log10 if specified)
  data2 <- data %>%
    dplyr::mutate(
      plot_x = if (log_x) log10(.data[[x]]) else .data[[x]],
      plot_y = if (log_y) log10(.data[[y]]) else .data[[y]])

  # Compute min and max for transformed variables
  min_x <- min(data2$plot_x, na.rm = TRUE)
  max_x <- max(data2$plot_x, na.rm = TRUE)
  min_y <- min(data2$plot_y, na.rm = TRUE)
  max_y <- max(data2$plot_y, na.rm = TRUE)

  # Normalize transformed values to [0, 1] for binning
  data2 <- dplyr::mutate(
    data2,
    x_bin = (plot_x - min_x) / (max_x - min_x),
    y_bin = (plot_y - min_y) / (max_y - min_y))

  # Create an empty raster grid for binning
  r <- terra::rast(
    nrow = nrow, ncol = ncol, xmin = 0L, xmax = 1L, ymin = 0L, ymax = 1L)

  # Rasterize points to count frequencies in bins
  rast_freq <- terra::rasterize(
    x = terra::vect(sf::st_as_sf(data2, coords = c("x_bin", "y_bin"))),
    y = r, field = 1L, fun = "count")
  terra::crs(rast_freq) <- NA

  # Clean up temporary data and garbage collect
  rm(data2)
  invisible(gc())

  # Compute original ranges for x and y
  x_range_orig <- range(data[[x]], na.rm = TRUE)
  y_range_orig <- range(data[[y]], na.rm = TRUE)

  # Compute breaks on original scale
  x_breaks_orig <- if (log_x) {
    scales::trans_breaks("log10", function(z) 10L^z, n = n_breaks)(x_range_orig)
  } else {
    scales::pretty_breaks(n = n_breaks)(x_range_orig)
  }
  y_breaks_orig <- if (log_y) {
    scales::trans_breaks("log10", function(z) 10L^z, n = n_breaks)(y_range_orig)
  } else {
    scales::pretty_breaks(n = n_breaks)(y_range_orig)
  }

  # Filter breaks to be within original data range
  x_breaks_orig <- x_breaks_orig[
    x_breaks_orig >= x_range_orig[1L] & x_breaks_orig <= x_range_orig[2L]] %>%
    unique() %>%
    sort()
  y_breaks_orig <- y_breaks_orig[
    y_breaks_orig >= y_range_orig[1L] & y_breaks_orig <= y_range_orig[2L]] %>%
    unique() %>%
    sort()

  # Compute corresponding breaks on transformed (plot) scale
  x_breaks_plot <- if (log_x) log10(x_breaks_orig) else x_breaks_orig
  y_breaks_plot <- if (log_y) log10(y_breaks_orig) else y_breaks_orig

  # Scale breaks to normalized [0, 1] space
  x_breaks_scaled <- (x_breaks_plot - min_x) / (max_x - min_x)
  y_breaks_scaled <- (y_breaks_plot - min_y) / (max_y - min_y)

  # Ensure matching lengths for breaks
  stopifnot(
    length(x_breaks_scaled) == length(x_breaks_orig),
    length(y_breaks_scaled) == length(y_breaks_orig))

  # Extract frequency values (discarding NAs)
  freq_vals <- terra::values(rast_freq) %>%
    as.numeric() %>%
    purrr::discard(is.na)

  # Define fill scale based on log_fill
  fill_scale <- if (log_fill) {
    ggplot2::scale_fill_viridis_c(
      option = "plasma", trans = "log10",
      breaks = scales::trans_breaks("log10", function(z) 10L^z, n = n_breaks)(
        range(freq_vals)),
      labels = scales::comma_format(),
      na.value = "transparent", name = "Frequency\n(log scale)",
      limits = c(min(freq_vals), max(freq_vals)),
      guide = ggplot2::guide_colorbar(
        barheight = ggplot2::unit(45L, "mm"),
        barwidth = ggplot2::unit(8L, "mm"),
        title.position = "top")
    )
  } else {
    fill_pretty <- scales::pretty_breaks(n = n_breaks)(range(freq_vals)) %>%
      unique() %>%
      sort()
    ggplot2::scale_fill_viridis_c(
      option = "plasma", breaks = fill_pretty,
      labels = scales::comma(round(fill_pretty)), name = "Frequency",
      na.value = "transparent",
      guide = ggplot2::guide_colorbar(
        barheight = ggplot2::unit(30L, "mm"),
        barwidth = ggplot2::unit(4L, "mm"),
        title.position = "top")
    )
  }

  # Set default axis labels if not provided
  # if (is.null(xlab)) {
  #   xlab <- if (log_x) paste(x, "(log10)") else x
  # }
  # if (is.null(ylab)) {
  #   ylab <- if (log_y) paste(y, "(log10)") else y
  # }

  # Create the ggplot object
  ggplot2::ggplot() +
    # Add light grid lines for reference
    ggplot2::geom_hline(
      yintercept = seq(0L, 1L, by = 0.1), color = "gray90", linewidth = 0.3) +
    ggplot2::geom_vline(
      xintercept = seq(0L, 1L, by = 0.1), color = "gray90", linewidth = 0.3) +
    # Add the raster layer
    tidyterra::geom_spatraster(data = rast_freq) +
    fill_scale +
    # Set x and y scales with custom breaks and labels
    ggplot2::scale_x_continuous(
      name = xlab, breaks = x_breaks_scaled,
      labels = scales::comma(x_breaks_orig)) +
    ggplot2::scale_y_continuous(
      name = ylab, breaks = y_breaks_scaled,
      labels = scales::comma(y_breaks_orig)) +
    ggplot2::labs(title = title, subtitle = subtitle) +
    ggplot2::coord_fixed(ratio = 1L, expand = FALSE, clip = "off") +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      plot.margin = ggplot2::margin(2L, 2L, 2L, 2L),
      plot.title = ggplot2::element_text(
        size = 14L, face = "bold", hjust = 0L, colour = "blue"),
      plot.subtitle = ggplot2::element_text(
        size = 12L, hjust = 0.5),
      axis.text.x = ggplot2::element_text(size = 9L),
      axis.text.y = ggplot2::element_text(size = 9L, angle = 90L),
      panel.grid.major = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank(),
      legend.position = "inside",
      legend.position.inside = c(0.925, 0.80),
      legend.title = ggplot2::element_blank(),
      legend.background = ggplot2::element_rect(
        fill = scales::alpha("white", 0.15),
        color = "white", linewidth = 0.5, linetype = "solid"))
}
