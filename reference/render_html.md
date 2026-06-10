# Render HTML text in the RStudio Viewer

Display one or more HTML strings in the RStudio Viewer pane. Each
element of `text` is rendered on a separate line/block while preserving
all HTML markup and CSS styling supported by the embedded browser used
by RStudio.

## Usage

``` r
render_html(
  text,
  title = "HTML Preview",
  css = NULL,
  background = "white",
  viewer_height = NULL
)
```

## Arguments

- text:

  Character vector containing HTML strings. Each element is rendered as
  a separate block.

- title:

  Character scalar specifying the HTML document title.

- css:

  Optional character scalar containing custom CSS. If `NULL`, a default
  stylesheet is used.

- background:

  Character scalar specifying the page background colour.

- viewer_height:

  Numeric scalar passed to
  [`utils::browseURL()`](https://rdrr.io/r/utils/browseURL.html) when
  supported by the current RStudio version.

## Value

Invisibly returns the path of the generated temporary HTML file.

## Details

This function is intended for interactive use inside RStudio only.

The function creates a temporary HTML document and opens it in the
RStudio Viewer pane.

Compared with console output, this approach supports:

- headings (`<h1>`-`<h6>`)

- bold, italic and underline formatting

- lists and tables

- inline CSS styling

- colours and fonts

- hyperlinks

- images

- SVG graphics

- MathJax equations (if included manually)

- arbitrary HTML fragments

Each element of `text` is wrapped in a separate `<div>` container.

## Examples

``` r
if (FALSE) { # \dontrun{

# --- 1. Basic typography and inline formatting ---
render_html(
  stringr::str_glue(
    "<h1>Typography</h1>",
    "<p>Plain paragraph with <b>bold</b>, <i>italic</i>,\
     <u>underline</u>, and \
     <code style='background:#f4f4f4;padding:2px 5px'>\
     inline code</code>.</p>",
    "<p><small>Small text</small> and <big>big text</big> and \
     <span style='color:steelblue;font-weight:600'>\
     coloured text</span>.</p>",
    "<hr>",
    "<blockquote style='border-left:4px solid #ccc;\
     margin:0;padding-left:1em;color:#555'>\
     A quoted passage or note.</blockquote>"
  )
)

# --- 2. Ordered and unordered lists ---
render_html(
  stringr::str_glue(
    "<h2>Model summary</h2>",
    "<ul>\
       <li>Species: <b>Quercus robur</b></li>\
       <li>Predictors: BIO4, BIO6, BIO18, BIO19, NPP</li>\
       <li>Spatial model: <code>TRUE</code></li>\
     </ul>",
    "<h2>Steps completed</h2>",
    "<ol>\
       <li>Data preparation</li>\
       <li>MCMC sampling &mdash; 1 000 posterior samples</li>\
       <li>Variance partitioning</li>\
       <li>Response curve computation</li>\
     </ol>"
  )
)

# --- 3. Side-by-side model comparison panels ---
render_html(
  stringr::str_glue(
    "<div style='display:flex;gap:2em'>\
       <div style='flex:1;background:#eef6fb;\
            padding:1em;border-radius:6px'>\
         <h3 style='margin-top:0;color:steelblue'>\
           Spatial model</h3>\
         <p>AUC: <b>0.91</b></p>\
         <p>TjurR2: <b>0.38</b></p>\
         <p>Convergence: \
            <span style='color:green'>&#10003; OK</span></p>\
       </div>\
       <div style='flex:1;background:#fef6ee;\
            padding:1em;border-radius:6px'>\
         <h3 style='margin-top:0;color:darkorange'>\
           Non-spatial model</h3>\
         <p>AUC: <b>0.87</b></p>\
         <p>TjurR2: <b>0.29</b></p>\
         <p>Convergence: \
            <span style='color:red'>&#10007; Warning</span></p>\
       </div>\
     </div>"
  )
)

# --- 4. Data table with conditional row colouring ---
species <- c(
  "Papilio machaon", "Pieris brassicae", "Vanessa atalanta"
)
auc <- c(0.94, 0.78, 0.88)
converged <- c(TRUE, FALSE, TRUE)
bg <- dplyr::case_when(
  !converged          ~ "#fff3cd",
  auc >= 0.9          ~ "#d4edda",
  .default            ~ "white"
)
flag <- ifelse(converged, "&#10003;", "&#9888;")
rows <- stringr::str_glue(
  "<tr style='background:{bg}'>\
     <td><i>{species}</i></td>\
     <td style='text-align:center'>{round(auc, 2)}</td>\
     <td style='text-align:center'>{flag}</td>\
   </tr>"
)
render_html(
  stringr::str_glue(
    "<h2>Per-species diagnostics</h2>",
    "<table border='1' cellpadding='6' cellspacing='0'\
      style='border-collapse:collapse;font-size:14px'>\
      <thead style='background:#f0f0f0'>\
        <tr>\
          <th>Species</th><th>AUC</th><th>Converged</th>\
        </tr>\
      </thead>\
      <tbody>{paste(rows, collapse = '')}</tbody>\
    </table>"
  )
)

# --- 5. Pipeline status badge dashboard ---
step_label <- c(
  "Prepare data", "Fit HMSC model",
  "MCMC convergence check",
  "Variance partitioning", "Response curves"
)
done  <- c(TRUE,  TRUE,  TRUE,  FALSE, FALSE)
warn  <- c(FALSE, FALSE, TRUE,  FALSE, FALSE)
colour <- dplyr::case_when(
  done & !warn ~ "#28a745",
  done &  warn ~ "#ffc107",
  .default     ~ "#6c757d"
)
icon  <- dplyr::case_when(
  done & !warn ~ "&#10003;",
  done &  warn ~ "&#9888;",
  .default     ~ "&#8230;"
)
label <- dplyr::case_when(
  done & !warn ~ "Done",
  done &  warn ~ "Warning",
  .default     ~ "Pending"
)
badges <- stringr::str_glue(
  "<div style='display:flex;align-items:center;\
    gap:0.6em;margin:4px 0'>\
    <span style='background:{colour};color:white;\
      padding:2px 8px;border-radius:12px;\
      font-size:12px'>{icon} {label}</span>\
    <span>{step_label}</span>\
  </div>"
)
render_html(
  c("<h2>Pipeline status</h2>", badges)
)

# --- 6. Inline SVG bar chart (variance partitioning) ---
vars    <- c("BIO4", "BIO6", "BIO18", "BIO19", "NPP")
vals    <- c(0.38, 0.27, 0.19, 0.10, 0.06)
colours <- c(
  "#4e79a7", "#f28e2b", "#59a14f", "#e15759", "#76b7b2"
)
bar_h <- 28L
gap   <- 8L
bar_w <- 300L
y     <- (seq_along(vars) - 1L) * (bar_h + gap)
w     <- round(vals * bar_w)
pct   <- round(vals * 100)
bars  <- stringr::str_glue(
  "<g>\
    <text x='45' y='{y + bar_h %/% 2L}' font-size='13'\
      dominant-baseline='middle' text-anchor='end'\
      font-family='sans-serif'>{vars}</text>\
    <rect x='50' y='{y}' width='{w}' height='{bar_h}'\
      fill='{colours}' rx='3'/>\
    <text x='{50L + w + 6L}' y='{y + bar_h %/% 2L}'\
      font-size='12' dominant-baseline='middle'\
      font-family='sans-serif' fill='#333'>{pct}%</text>\
  </g>"
)
svg_h <- length(vars) * (bar_h + gap) - gap + 10L
render_html(
  stringr::str_glue(
    "<h2>Variance partitioning &mdash; fixed effects</h2>",
    "<svg width='460' height='{svg_h}'\
      xmlns='http://www.w3.org/2000/svg'>\
      {paste(bars, collapse = '')}\
    </svg>"
  )
)

# --- 7. Collapsible log sections via <details> ---
render_html(
  stringr::str_glue(
    "<h2>Model run log</h2>",
    "<details open>\
       <summary style='cursor:pointer;font-weight:600'>\
         Chain 1</summary>\
       <pre style='background:#f8f8f8;\
            padding:0.8em;font-size:12px'>\
Iteration   100 / 1000\
Iteration   200 / 1000\
Rhat max: 1.003 &mdash; OK</pre>\
     </details>",
    "<details>\
       <summary style='cursor:pointer;font-weight:600'>\
         Chain 2</summary>\
       <pre style='background:#f8f8f8;\
            padding:0.8em;font-size:12px'>\
Iteration   100 / 1000\
Iteration   200 / 1000\
Rhat max: 1.041 &mdash; WARNING</pre>\
     </details>"
  )
)

# --- 8. Custom dark theme for SLURM output ---
dark_css <- stringr::str_glue(
  "body {{background:#1e1e1e;color:#d4d4d4;\
    font-family:'Consolas','Courier New',monospace;\
    margin:20px}}\
   h2 {{color:#9cdcfe}}\
   code {{color:#ce9178}}\
   .kv {{display:flex;gap:2em;margin:4px 0}}\
   .key {{color:#4ec9b0;min-width:160px}}"
)
render_html(
  stringr::str_glue(
    "<h2>SLURM job summary</h2>",
    "<div class='kv'>\
       <span class='key'>Job ID</span>\
       <code>8841023</code></div>",
    "<div class='kv'>\
       <span class='key'>Partition</span>\
       <code>gpu</code></div>",
    "<div class='kv'>\
       <span class='key'>Nodes</span>\
       <code>4 &times; LUMI-G</code></div>",
    "<div class='kv'>\
       <span class='key'>Wall time</span>\
       <code>11h 42m</code></div>",
    "<div class='kv'>\
       <span class='key'>Status</span>\
       <code style='color:#4ec9b0'>COMPLETED</code></div>"
  ),
  title = "SLURM summary",
  css = dark_css,
  background = "#1e1e1e"
)

} # }
```
