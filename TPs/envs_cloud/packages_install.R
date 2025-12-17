# --- 1. Global Setup ---
# Set the CRAN mirror globally so you don't have to type it every time.
options(repos = c(CRAN = "https://cloud.r-project.org"))

# --- 2. Setup BiocManager ---
if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

# --- 3. Define Package Lists ---
bioc_pkgs <- c("maftools", "BSgenome", "BSgenome.Hsapiens.UCSC.hg19", "MutationalPatterns", "GenomicDataCommons")
cran_pkgs <- c("rmarkdown", "RColorBrewer", "glmnet", "dplyr", "tidyr", "DT", "kableExtra",
               "yarrr", "knitr", "randomForest", "ICAMS", "googledrive", "gtools", "patchwork")

# --- 4. Install Missing Packages in Bulk ---

# Check/Install Bioconductor
missing_bioc <- bioc_pkgs[!(bioc_pkgs %in% installed.packages()[,"Package"])]
if(length(missing_bioc) > 0) {
  message("Installing missing Bioconductor packages...")
  BiocManager::install(missing_bioc, update = FALSE, ask = FALSE)
}

# Check/Install CRAN
missing_cran <- cran_pkgs[!(cran_pkgs %in% installed.packages()[,"Package"])]
if(length(missing_cran) > 0) {
  message("Installing missing CRAN packages...")
  # No need to specify repo here because we set it in 'options' above
  install.packages(missing_cran)
}

# --- 5. Load All Packages ---
all_pkgs <- c(bioc_pkgs, cran_pkgs)
invisible(lapply(all_pkgs, function(pkg) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    warning(paste("Package", pkg, "failed to load!"))
  }
}))
