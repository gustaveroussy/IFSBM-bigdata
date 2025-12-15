#!/bin/bash
set -e

# --- Install Helper ---
install_if_needed() {
    PACKAGE_NAME="$1"
    INSTALL_COMMAND="$2"

    Rscript -e "if(requireNamespace('$PACKAGE_NAME', quietly=TRUE)) quit(save='no', status=0) else quit(save='no', status=1)" || \
    {
        echo "Installing $PACKAGE_NAME..."
        Rscript -e "$INSTALL_COMMAND"
    }
}


# --- 1. Complex/Compilation-Heavy Packages/Failing for osx-arm-64
REPO="https://cloud.r-project.org"
export PKG_CPPFLAGS="-DHAVE_WORKING_LOG1P"
install_if_needed "yarrr" "install.packages('yarrr', repos='$REPO')"
install_if_needed "maftools" "BiocManager::install('maftools', update=F)"
install_if_needed "MutationalPatterns" "BiocManager::install('MutationalPatterns', update=F)"
install_if_needed "sigminer" "install.packages('sigminer', repos='$REPO')"
install_if_needed "ICAMS" "options(download.file.method='libcurl'); remotes::install_github('steverozen/ICAMS@v3.0.11-branch', upgrade='never')"
