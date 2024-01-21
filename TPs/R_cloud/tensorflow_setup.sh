#!/bin/bash

# set PATH
export PATH="${HOME}/miniconda3/bin:${HOME}/miniconda3/condabin:$PATH"

# install mamba
source activate ${HOME}/miniconda3

# install env
if [[ -d "${HOME}/miniconda3/envs/tensorflow" ]]; then
  printf "INFO: conda environment 'tensorflow' already exists, delete it if you want to recreate it. You may delete the environment by running conda env remove --name 'tensorflow' --all\n"
else
  mamba env create -f TPs/R_cloud/tensorflow.yaml
fi
