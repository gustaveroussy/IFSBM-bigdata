# solves Python error "RuntimeError: module compiled against API version 0x10 but this version of numpy is 0xf"
python -m pip install numpy --upgrade

# solves R error "error: no member named 'Rlog1p' in namespace 'std'; did you mean simply 'Rlog1p'?"
export PKG_CPPFLAGS="-DHAVE_WORKING_LOG1P"
Rscript -e "install.packages('yarrr', repos='http://cran.us.r-project.org')"

# if facing issues with DNAcopy package, check this post https://github.com/PoisonAlien/maftools/issues/886
## check the instructions here https://github.com/Bioconductor/BBS/blob/devel/Doc/Prepare-macOS-Big-Sur-HOWTO.md
## to build with the minimum MacOSX version supported by CRAN as of April 2023
#export SDKROOT=/Library/Developer/CommandLineTools/SDKs/MacOSX11.sdk
#export MACOSX_DEPLOYMENT_TARGET=11.0
#export PATH="/opt/gfortran/bin:$PATH"
Rscript -e "BiocManager::install('maftools', update=F)"
Rscript -e "BiocManager::install('maftools', update=F)"
Rscript -e "BiocManager::install('MutationalPatterns', update=F)"
Rscript -e "BiocManager::install('BSgenome.Hsapiens.UCSC.hg19', update=F)"

# packages not available via conda
Rscript -e "install.packages('ICAMS', repos='http://cran.us.r-project.org')"
