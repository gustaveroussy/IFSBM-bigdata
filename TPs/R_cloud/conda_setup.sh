#!/bin/bash

cd $HOME

# install miniconda3
mkdir -p miniconda3
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda3/miniconda.sh
bash miniconda3/miniconda.sh -b -u -p miniconda3
rm -rf $HOME/miniconda3/miniconda.sh

# set PATH
export PATH="${HOME}/miniconda3/bin:${HOME}/miniconda3/condabin:$PATH"

# install mamba
source activate ${HOME}/miniconda3
conda install -y -c conda-forge mamba
