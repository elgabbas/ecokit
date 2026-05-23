#' Get Sampling Effort Rasters
#'
#' Downloads sampling effort raster files from the Open Science Framework (OSF)
#' based on specified taxonomic groups, descendants, metrics, years, and spatial
#' resolution. The function validates all inputs and retrieves corresponding
#' raster data files. Valid descendants for each group can be retrieved with
#' `get_group_descendants()`. For more information, see [this
#' repo](https://github.com/elgabbas/global_sampling_efforts/) and *El-Gabbas
#' (2026). Diversity and Distributions [DOI](https://doi.org/10.1111/ddi.70205).
#'
#' @param group Character. The taxonomic group to download sampling effort data
#'   for. Must be one of: "all", "amphibia", "arachnida", "aves", "fungi",
#'   "insecta", "mammalia", "mollusca", "reptilia", or "tracheophyta". "all"
#'   refers to the overall sampling effort across all groups. Required.
#' @param descendants A character vector of descendants for the chosen group.
#'   Valid descendants vary by group. Defaults to "all" to download data for all
#'   descendants combined for the chosen group. Use `get_group_descendants()` to
#'   retrieve valid descendants for a given group. Required.
#' @param metric A character string specifying the metric to download. Must be
#'   either "n_sp" (number of species) or "n_obs" (number of observations).
#'   Required.
#' @param years A numeric vector or character string specifying year(s) to
#'   download. Valid range is 1980 to 2025, or "total" (default) for overall
#'   efforts. Automatically set to "total" when group is "all". Required for
#'   other groups.
#' @param resolution A numeric value specifying the spatial resolution in
#'   kilometers. Must be one of: 1, 5, 10, or 20 km. Required.
#' @param out_dir A character string specifying the output directory path.
#'   Defaults to the current working directory. If the directory does not exist,
#'   it will be created.
#' @param conflicts A character string specifying how to handle existing files.
#'   Must be either "skip" (default) or "overwrite".
#' @param verbose Logical. If `TRUE`, prints progress messages during the
#'   download process. Defaults to `FALSE`.
#'
#' @return A tibble containing downloaded sampling effort data with columns:
#'   - `group`: The taxonomic group
#'   - `descendant`: The taxonomic descendant
#'   - `year`: The year of the data
#'   - `metric`: The metric type (`n_sp` or `n_obs`)
#'   - `resolution`: The spatial resolution in km
#'   - `name`: The name of the downloaded file
#'   - `id`: The OSF file ID
#'   - `local_path`: The local file path where the raster was downloaded
#'   - `meta`: Metadata about the downloaded file from OSF
#'
#' @details
#'
#' This function downloads sampling effort raster files from the OSF project.
#' This function complements the manuscript **"A Global, Taxon-Stratified,
#' High-Resolution Sampling-Effort Dataset From GBIF for Bias-Aware Ecological
#' Modelling"** by providing a programmatic way to access the underlying data
#' used in the study. Please cite the manuscript when using the data retrieved
#' by this function.
#'
#' Files on the OSF project are organized hierarchically by group, resolution,
#' metric, and descendant-year combinations.
#'
#' This function retrieves sampling effort rasters based on the specified group
#' and its descendants. The `descendants` argument allows users to specify which
#' descendant groups to download data for. The function validates descendants
#' using `ecokit::get_group_descendants()` and retrieves the corresponding
#' raster files from OSF.
#'
#' Use `ecokit::get_group_descendants()` to retrieve all valid descendants for a
#' given taxonomic group.
#'
#' @references El-Gabbas, A. (2026). A Global, Taxon-Stratified, High-Resolution
#'   Sampling-Effort Dataset From GBIF for Bias-Aware Ecological Modelling.
#'   Diversity and Distributions. [DOI](https://doi.org/10.1111/ddi.70205).
#'
#' @examples
#' require(terra)
#'
#' # Retrieve valid descendants for a group
#' get_group_descendants("insecta")
#'
#' # Retrieve descendants for all groups
#' get_group_descendants("all")
#'
#' # |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
#'
#' # Occurrence count for birds at 20 km resolution
#' efforts_birds_all <- get_sampling_effort(
#'   group = "aves", metric = "n_obs", resolution = 20)
#'
#' dplyr::glimpse(efforts_birds_all)
#'
#' efforts_birds_all_r <- terra::rast(efforts_birds_all$local_path)
#'
#' # Plot at log10 scale
#' terra::classify(efforts_birds_all_r, cbind(0, NA)) %>%
#'   terra::crop(terra::ext(-125, -66.5, 24.5, 49.5)) %>%
#'   log10() %>%
#'   plot()
#'
#' # |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
#'
#' # Occurrence count for insecta at 10 km resolution in 2020
#' efforts_insecta_2020 <- get_sampling_effort(
#'   group = "insecta", descendants = "all",
#'   metric = "n_obs", years = 2020, resolution = 10)
#'
#' efforts_insecta_2020_r <- terra::rast(efforts_insecta_2020$local_path)
#'
#' # Plot at log10 scale
#' terra::classify(efforts_insecta_2020_r, cbind(0, NA)) %>%
#'   terra::crop(terra::ext(-125, -66.5, 24.5, 49.5)) %>%
#'   log10() %>%
#'   plot()
#'
#' # |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
#'
#' # Species count for vascular plants at 10 km
#' efforts_plants_2020 <- get_sampling_effort(
#'   group = "tracheophyta", descendants = "all",
#'   metric = "n_sp", resolution = 10)
#'
#' efforts_plants_2020_r <- terra::rast(efforts_plants_2020$local_path)
#'
#' # Plot at log10 scale
#' terra::classify(efforts_plants_2020_r, cbind(0, NA)) %>%
#'   terra::crop(terra::ext(-125, -66.5, 24.5, 49.5)) %>%
#'   log10() %>%
#'   plot()
#'
#' # |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
#'
#' # Occurrence count for selected insect groups (descendants) at 10 km
#' efforts_insects <- get_sampling_effort(
#'   group = "insecta",
#'   descendants = c("hemiptera", "hymenoptera", "lepidoptera"),
#'   metric = "n_obs", resolution = 10)
#'
#' efforts_insects
#'
#' dplyr::glimpse(efforts_insects)
#'
#' efforts_insects_r <- terra::rast(efforts_insects$local_path)
#' efforts_insects_r
#'
#' # Plot at log10 scale
#' terra::classify(efforts_insects_r, cbind(0, NA)) %>%
#'   terra::crop(terra::ext(-125, -66.5, 24.5, 49.5)) %>%
#'   stats::setNames(c("hemiptera", "hymenoptera", "lepidoptera")) %>%
#'   log10() %>%
#'   plot()
#' @export

#' @author Ahmed El-Gabbas
#' @name sampling_effort
#' @rdname sampling_effort
#' @order 2
#' @export

get_sampling_effort <- function(
    group = NULL, descendants = "all", metric = NULL, years = "total",
    resolution = NULL, out_dir = getwd(), conflicts = "skip", verbose = FALSE) {

  year <- descendant <- name2 <- name <- NULL

  # ++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
  # Validate packages ----
  # ++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

  ecokit::check_packages(
    c("terra", "osfr", "purrr", "fs", "dplyr", "tidyr", "stringr", "tibble"))

  # |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| #
  # |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| #

  # ++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
  # Validate inputs ----
  # ++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

  ## ------------------------------------------------------
  ## group ----
  ## ------------------------------------------------------

  valid_groups <- c(
    "all", "amphibia", "arachnida", "aves", "fungi", "insecta", "mammalia",
    "mollusca", "reptilia", "tracheophyta")

  if (is.null(group)) {
    ecokit::stop_ctx(
      paste0(
        "Group cannot be missing. Please specify one of the following: ",
        toString(valid_groups), "."))
  }

  if (length(group) != 1L) {
    ecokit::stop_ctx(
      "Group must be a single character string.", group = group,
      length_group = length(group))
  }

  if (!is.character(group)) {
    ecokit::stop_ctx(
      "Group must be a character string.",
      group = group, class_group = class(group))
  }

  group <- stringr::str_trim(stringr::str_to_lower(group))

  if (!group %in% valid_groups) {
    ecokit::stop_ctx(
      "Invalid group.", group = group, valid_groups = valid_groups)
  }

  ## ------------------------------------------------------
  ## descendants ----
  ## ------------------------------------------------------

  valid_descendants <- get_group_descendants(group = "all")

  if (is.null(descendants)) {
    ecokit::stop_ctx(
      paste0(
        "`descendants` cannot be missing. Please specify a valid ",
        "descendant or set to 'all' for all descendants of the chosen group."),
      group = group, descendants = descendants,
      valid_descendants = valid_descendants[[group]])
  }

  if (!is.character(descendants)) {
    ecokit::stop_ctx("descendants must be a character vector.")
  }

  descendants <- tolower(descendants)

  # Check if descendants is valid for the chosen group
  if (!all(descendants %in% valid_descendants[[group]])) {
    ecokit::stop_ctx(
      paste0(
        "Invalid descendants for the chosen group. Please choose from: ",
        toString(valid_descendants[[group]]), "."))
  }

  ## ------------------------------------------------------
  ## metric ----
  ## ------------------------------------------------------

  if (is.null(metric)) {
    ecokit::stop_ctx(
      paste0(
        "Metric cannot be missing. Please specify 'n_sp' for number of ",
        "species and/or 'n_obs' for number of observations.")) #nolint
  }

  if (length(metric) > 1L) {
    ecokit::stop_ctx("Metric must be a single character string.")
  }

  metric <- tolower(metric)

  if (!metric %in% c("n_sp", "n_obs")) {
    ecokit::stop_ctx(
      paste0(
        "Invalid metric. Please choose 'n_sp' for number of species or ",
        "'n_obs' for number of observations."))
  }

  ## ------------------------------------------------------
  ## years ----
  ## ------------------------------------------------------


  if (group == "all") {

    years <- "total"

  } else {

    if (is.null(years)) {
      ecokit::stop_ctx(paste0("`years` cannot be missing for group '", group))
    }

    valid_years <- c("total", seq(1980L, 2025L))
    years <- as.character(years)

    if (!all(years %in% valid_years)) {
      ecokit::stop_ctx(
        paste0(
          "Invalid years. Please specify year(s) between 1980 and ",
          "2025 or `total` for the overall efforts."),
        valid_years = valid_years, years = years)
    }
  }

  ## ------------------------------------------------------
  ## resolution ----
  ## ------------------------------------------------------

  valid_resolutions <- c(1L, 5L, 10L, 20L)

  if (is.null(resolution)) {
    ecokit::stop_ctx(
      paste0(
        "Resolution cannot be missing. Please specify a resolution of: ",
        toString(valid_resolutions), " km."))
  }

  if (length(resolution) != 1L) {
    ecokit::stop_ctx(
      "Resolution must be a single numeric value.", resolution = resolution)
  }

  if (!is.numeric(resolution)) {
    ecokit::stop_ctx(
      "Resolution must be a numeric value.",
      class_resolution = class(resolution))
  }

  if (!resolution %in% valid_resolutions) {
    ecokit::stop_ctx(
      paste0(
        "Resolution must be one of the following: ",
        toString(valid_resolutions), " km."),
      resolution = resolution)
  }

  ## ------------------------------------------------------
  ## out_dir ----
  ## ------------------------------------------------------

  if (is.null(out_dir)) {
    ecokit::stop_ctx(
      paste0(
        "`out_dir` cannot be missing. Please specify a valid output ",
        "directory path"))
  }

  if (!is.character(out_dir) || length(out_dir) != 1L) {
    ecokit::stop_ctx(
      "Output directory must be a single character string.",
      out_dir = out_dir, class_out_dir = class(out_dir),
      length_out_dir = length(out_dir))
  }

  if (fs::dir_exists(out_dir)) {
    if (!fs::is_dir(out_dir)) {
      ecokit::stop_ctx(
        "Output path exists but is not a directory.", out_dir = out_dir)
    }
  } else {
    fs::dir_create(out_dir)
  }

  ## ------------------------------------------------------
  ## conflicts ----
  ## ------------------------------------------------------


  if (is.null(conflicts)) {
    ecokit::stop_ctx(
      paste0(
        "`conflicts` cannot be missing.  Please choose one of the following: ",
        "'skip' or 'overwrite'"))
  }

  if (!conflicts %in% c("skip", "overwrite")) {
    ecokit::stop_ctx(
      paste0(
        "Invalid conflicts argument. Please choose one of the following: ",
        "'skip' or 'overwrite'"))
  }

  # |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| #
  # |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| #

  # ++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
  # Retrieve sampling effort raster from OSF based on validated inputs
  # ++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

  node_lists <- osfr::osf_retrieve_node("hz4sy") %>%
    osfr::osf_ls_nodes() %>%
    dplyr::mutate(name2 = stringr::str_to_lower(name))

  if (group == "all") {
    node_lists <- dplyr::filter(
      node_lists, name2 == "global sampling effort rasters")
  } else {
    node_lists <- dplyr::filter(node_lists, stringr::str_detect(name2, group))
  }

  if (nrow(node_lists) != 1L) {
    ecokit::stop_ctx(
      paste0(
        "Expected exactly one OSF node for group '", group,
        "'. Found ", nrow(node_lists), "."))
  }


  effort_data <- tibble::tibble(descendant = valid_descendants[[group]]) %>%
    dplyr::mutate(group = group, .before = 1L) %>%
    dplyr::filter(descendant %in% descendants) %>%
    tidyr::expand_grid(
      year = years, metric = metric, resolution = resolution) %>%
    dplyr::mutate(
      effort_down = purrr::pmap(
        list(group, descendant, year, metric, resolution),
        function(group, descendant, year, metric, resolution) {

          ecokit::cat_time(
            paste0(group, ": ", descendant, "; year: ", year),
            verbose = verbose)

          if (group == "all") {

            descendant_year <- paste0(metric, "_", resolution, ".tif")
            r_file <- osfr::osf_retrieve_node(node_lists$id) %>%
              osfr::osf_ls_files(type = "file", pattern = descendant_year)

          } else {

            res_metric <- paste0("res_", resolution, "_", metric)

            if (year == "total") {
              if (descendant == "all") {
                descendant_year <- paste0(group, "_res")
              } else {
                descendant_year <- paste0("_", descendant, "_total_res")
              }
            } else if (descendant == "all") {
              descendant_year <- paste0(group, "_", year)
            } else {
              descendant_year <- paste0("_", descendant, "_", year)
            }

            r_file <- osfr::osf_retrieve_node(node_lists$id) %>%
              osfr::osf_ls_files(
                n_max = 15L, type = "folder", pattern = res_metric) %>%
              osfr::osf_ls_files(type = "file", pattern = descendant_year)
          }

          if (nrow(r_file) != 1L) {
            ecokit::stop_ctx(
              paste0(
                "Expected exactly one file for metric '", metric,
                "' and descendant-year '", descendant, " - ", year,
                "'. Found ", nrow(r_file), " files."))
          }

          Sys.sleep(2L)
          osfr::osf_download(x = r_file, path = out_dir, conflicts = conflicts)

        })) %>%
    tidyr::unnest("effort_down")

  effort_data
}


#' @author Ahmed El-Gabbas
#' @name sampling_effort
#' @rdname sampling_effort
#' @order 1
#' @export

get_group_descendants <- function(group = NULL) {

  valid_descendants <- list(
    all = "all",

    amphibia = c("all", "anura", "caudata", "gymnophiona"),

    arachnida = c(
      "all", "amblypygi", "araneae", "holothyrida", "ixodida", "mesostigmata",
      "opilioacarida", "opiliones", "palpigradi", "pseudoscorpiones",
      "ricinulei", "sarcoptiformes", "schizomida", "scorpiones", "solifugae",
      "trombidiformes", "uropygi"),

    aves = c(
      "all", "accipitriformes", "anseriformes", "apodiformes", "apterygiformes",
      "bucerotiformes", "caprimulgiformes", "cariamiformes", "casuariiformes",
      "charadriiformes", "ciconiiformes", "coliiformes", "columbiformes",
      "coraciiformes", "cuculiformes", "eurypygiformes", "falconiformes",
      "galliformes", "gaviiformes", "gruiformes", "leptosomiformes",
      "mesitornithiformes", "musophagiformes", "nyctibiiformes",
      "opisthocomiformes", "otidiformes", "passeriformes", "pelecaniformes",
      "phaethontiformes", "phoenicopteriformes", "piciformes",
      "podicipediformes", "procellariiformes", "psittaciformes",
      "pteroclidiformes", "rheiformes", "sphenisciformes", "steatornithiformes",
      "strigiformes", "struthioniformes", "suliformes", "tinamiformes",
      "trogoniformes"),

    fungi = c(
      "all", "ascomycota", "basidiomycota", "blastocladiomycota",
      "chytridiomycota", "entomophthoromycota", "glomeromycota", "mucoromycota",
      "neocallimastigomycota", "sanchytriomycota", "zoopagomycota",
      "zygomycota"),

    insecta = c(
      "all", "archaeognatha", "blattodea", "cnemidolestodea", "coleoptera",
      "dermaptera", "diptera", "embioptera", "ephemeroptera", "grylloblattodea",
      "hemiptera", "hymenoptera", "lepidoptera", "mantodea", "mantophasmatodea",
      "mecoptera", "megaloptera", "neuroptera", "odonata", "orthoptera",
      "palaeodictyoptera", "phasmida", "plecoptera", "protorthoptera",
      "psocodea", "raphidioptera", "siphonaptera", "strepsiptera",
      "thysanoptera", "trichoptera", "zoraptera", "zygentoma"),

    mammalia = c(
      "all", "afrosoricida", "artiodactyla", "carnivora", "cetacea",
      "chiroptera", "cingulata", "dasyuromorphia", "dermoptera",
      "didelphimorphia", "diprotodontia", "erinaceomorpha", "hyracoidea",
      "lagomorpha", "macroscelidea", "microbiotheria", "monotremata",
      "notoryctemorphia", "paucituberculata", "peramelemorphia",
      "perissodactyla", "pholidota", "pilosa", "primates", "proboscidea",
      "rodentia", "scandentia", "sirenia", "soricomorpha", "tubulidentata"),

    mollusca = c(
      "all", "bivalvia", "caudofoveata", "cephalopoda", "cricoconarida",
      "gastropoda", "monoplacophora", "polyplacophora", "rostroconchia",
      "scaphopoda", "solenogastres"),

    reptilia = c("all", "crocodylia", "sphenodontia", "squamata", "testudines"),

    tracheophyta = c(
      "all", "cycadopsida", "ginkgoopsida", "gnetopsida", "liliopsida",
      "lycopodiopsida", "magnoliopsida", "pinopsida", "polypodiopsida")
  )

  if (group == "all") {
    return(valid_descendants)
  }

  group <- stringr::str_trim(stringr::str_to_lower(group))
  if (!group %in% names(valid_descendants)) {
    ecokit::stop_ctx(
      "Invalid group.", group = group, valid_groups = names(valid_descendants))
  }
  return(valid_descendants[[group]])
}



# Top / lowest observation areas -------


#' Mask raster to show top % and bottom % of cumulative sum
#'
#' This function complements the `get_sampling_effort()` function by creating
#' masked rasters that highlight areas contributing to the top and bottom
#' percentages of the cumulative sum of the original raster values. This can be
#' useful for identifying areas with the highest and lowest sampling efforts
#' based on the original raster (i.e., number of observations). The function
#' also identifies cells with zero observations. For more information, see [this
#' repo](https://github.com/elgabbas/global_sampling_efforts/) and *El-Gabbas
#' (2026). Diversity and Distributions [DOI](https://doi.org/10.1111/ddi.70205)
#'
#' @param rast A SpatRaster object with numeric values (e.g., counts per cell)
#' @param top_pct Numeric, percentage (0–100) for the top cumulative sum
#'   (default: 90)
#' @return A SpatRaster with three layers:
#'   - `top_xx_percent_cumulative`: cells cumulatively accounting for the top
#'   `top_pct`%; where `xx` is the value of `top_pct`
#'   - `bottom_xx_percent_cumulative`: cells cumulatively accounting for the
#'   lowest `(100 - top_pct)`%; where `xx` is the value of `top_pct`
#'   - `zero_observations`: cells with original value equal to zero
#' @examples
#' require(terra)
#'
#' # Sampling effort raster for birds (number of observations at 20 km
#' # resolution)
#' efforts_birds_all <- get_sampling_effort(
#'   group = "aves", metric = "n_obs", resolution = 20)
#' efforts_birds_all_r <- terra::rast(efforts_birds_all$local_path)
#'
#' result <- mask_cumulative_pct(rast = efforts_birds_all_r, top_pct = 90)
#' result
#'
#' # Areas contributing to the top 90% of cumulative sum (log10 scale; computed
#' # on the global scale and cropped to USA)
#' result$top_90_percent_cumulative %>%
#'   terra::crop(terra::ext(-125, -66.5, 24.5, 49.5)) %>%
#'   log10() %>%
#'   plot()
#'
#' # Areas contributing to the lowest 10% of cumulative sum (log10 scale;
#' # computed on the global scale and cropped to USA)
#' result$lowest_10_percent_cumulative %>%
#'   terra::crop(terra::ext(-125, -66.5, 24.5, 49.5)) %>%
#'   log10() %>%
#'   plot()
#'
#' # Areas with zero observations (computed on the global scale and cropped to
#' # USA)
#' result$zero_observations %>%
#'   terra::crop(terra::ext(-125, -66.5, 24.5, 49.5)) %>%
#'   plot()
#'
#' @export

mask_cumulative_pct <- function(rast, top_pct = 90L) {

  # Validate input
  if (!inherits(rast, "SpatRaster")) {
    ecokit::stop_ctx(
      "`rast` must be a SpatRaster object.",
      rast = rast, class_rasr = class(rast))
  }

  if (!is.numeric(top_pct) || length(top_pct) != 1L) {
    ecokit::stop_ctx(
      "`top_pct` must be a single numeric value.",
      top_pct = top_pct, class_top_pct = class(top_pct),
      length_top_pct = length(top_pct))
  }

  if (top_pct <= 0L || top_pct >= 100L) {
    ecokit::stop_ctx(
      "`top_pct` must be between 0 and 100 (exclusive).",
      top_pct = top_pct)
  }

  terra::terraOptions(memfrac = 0.05, todisk = TRUE, memmax = 1e5L)

  rast_0 <- (rast == 0L) %>%
    terra::classify(cbind(0L, NA)) %>%
    terra::as.factor() %>%
    setNames("zero_observations")

  rast <- terra::classify(rast, cbind(0L, NA))

  # Extract all cell values
  vals <- terra::values(rast, na.rm = FALSE)
  not_na <- !is.na(vals)

  # Total sum of non-NA values
  total_sum <- sum(vals[not_na], na.rm = TRUE)

  if (total_sum == 0L) {
    warning("Total sum is zero. Returning all-NA rasters.", call. = FALSE)
    rast_top <- rast_bottom <- rast
    terra::values(rast_top) <- NA
    terra::values(rast_bottom) <- NA
    return(terra::rast(top = rast_top, bottom = rast_bottom))
  }

  bottom_pct <- 100L - top_pct
  top_threshold <- total_sum * (top_pct / 100L)
  bottom_threshold <- total_sum * (bottom_pct / 100L)

  # === TOP: Highest values contributing to top_pct % ===
  order_desc <- order(vals, decreasing = TRUE, na.last = NA)
  vals_desc <- vals[order_desc]
  cumsum_desc <- cumsum(vals_desc)

  # First index where cumulative sum >= threshold
  n_top <- which(cumsum_desc >= top_threshold)[1L]
  if (is.na(n_top)) n_top <- length(cumsum_desc)  # fallback

  cell_ids_top <- order_desc[seq_len(n_top)]

  rast_top <- rast
  terra::values(rast_top) <- NA
  rast_top[cell_ids_top] <- vals[cell_ids_top]

  # === BOTTOM: Lowest values contributing to bottom_pct % ===
  order_asc <- order(vals, decreasing = FALSE, na.last = NA)
  vals_asc <- vals[order_asc]
  cumsum_asc <- cumsum(vals_asc)

  n_bottom <- which(cumsum_asc >= bottom_threshold)[1L]
  if (is.na(n_bottom)) n_bottom <- length(cumsum_asc)

  cell_ids_bottom <- order_asc[seq_len(n_bottom)]

  rast_bottom <- rast
  terra::values(rast_bottom) <- NA
  rast_bottom[cell_ids_bottom] <- vals[cell_ids_bottom]

  # Set names
  names(rast_top) <- paste0("top_", top_pct, "_percent_cumulative")
  names(rast_bottom) <- paste0("lowest_", bottom_pct, "_percent_cumulative")

  c(rast_top, rast_bottom, rast_0) %>%
    terra::toMemory()
}
