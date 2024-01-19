#!/bin/bash

# set PATH
export PATH="${HOME}/miniconda3/bin:${HOME}/miniconda3/condabin:$PATH"

# install mamba
source activate ${HOME}/miniconda3

# install env
if [[ -d "${HOME}/miniconda3/envs/r_tp1" ]]; then
  printf "INFO: conda environment 'r_tp1' already exists, delete it if you want to recreate it. You may delete the environment by running conda env remove --name 'r_tp1' --all\n"
else
  mamba env create -f TPs/R_TP1/r_tp1.yaml
fi

# set up ~/.profile so that Rstudio loads the R interpreter
echo "export RSTUDIO_WHICH_R=${HOME}/miniconda3/envs/r_tp1/bin/R" > ~/.profile
echo "export RSTUDIO_DISABLE_PACKAGE_INSTALL_PROMPT=1" >> ~/.profile
echo "export R_LIBS_USER=${HOME}/miniconda3/envs/r_tp1/lib/R/library" >> ~/.profile
echo "export R_LIBS_SITE=${HOME}/miniconda3/envs/r_tp1/lib/R/library" >> ~/.profile
