if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

# packages installable via BiocManager::install
packages_biocmanager_required <- c("maftools", "BSgenome", "BSgenome.Hsapiens.UCSC.hg19", "MutationalPatterns")
for (package_biocmanager_required in packages_biocmanager_required){
  if (!require(package_biocmanager_required, quietly = TRUE))
    BiocManager::install(package_biocmanager_required)
}

# packages installable via install.packages
packages_required <- c("rmarkdown", "RColorBrewer", "glmnet", "dplyr", "tidyr", "yarrr", "knitr",
                       "keras", "ICAMS")

for (package_required in packages_required){
  if (!require(package_required, quietly = TRUE))
    install.packages(package_required)
}


