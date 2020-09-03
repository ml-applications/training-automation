#!/bin/bash
# Simple automation of glow-tts training routines
# Meant to run on deployed boxes, eg. LambdaLabs
# This could also be a Dockerfile...

set -euxo pipefail

# Model name is a string identifier in [a-z\-]
model_name=${1}

function install_cuda() {
  CUDA_URL="https://developer.nvidia.com/compute/cuda/10.0/Prod/local_installers/cuda_10.0.130_410.48_linux"
  CUDA_PATH="${HOME}/cuda.run"
  if [ ! -f $CUDA_PATH ]; then
    wget $CUDA_URL -O ${HOME}/cuda.run;
  fi
  if [ ! -d "/usr/local/cuda-10.0/" ]; then
    sudo sh $CUDA_PATH --silent --toolkit --override;
  fi
}

mkdir -p /home/ubuntu/data
mkdir -p /home/ubuntu/code

install_cuda;

sudo apt-get install \
  -y \
  build-essential \
  libffi-dev \
  libsndfile1 \
  libssl-dev \
  python-dev \
  python3.7 \
  python3.7-dev \
  python3.7-venv \
  ripgrep \
  silversearcher-ag

cd /home/ubuntu/code
git clone https://github.com/ml-applications/glow-tts.git

code_dir="glow-tts-${model_name}/"

mv "glow-tts/" "${code_dir}"
cd "${code_dir}"

# Make sure the repo is in its final directory location, otherwise venv hates you
python3.7 -m venv python
source python/bin/activate
pip install --upgrade pip
pip install -r requirements-lambda.txt

# Here we need to use GCC 7 instead of 9.
# Cuda 10 doesn't like GCC beyond version 7
sudo rm /usr/bin/gcc
sudo rm /usr/bin/g++
sudo ln -s /usr/bin/gcc-7 /usr/bin/gcc
sudo ln -s /usr/bin/g++-7 /usr/bin/g++

# TODO: Use checks here to not change the symlinks if already updated.
gcc --version
g++ --version

export CC=gcc-7
export CPP=g++-7
export CXX=g++-7
export LD=g++-7
export CUDA_HOME=/usr/local/cuda-10.0
export LD_LIBRARY_PATH=/usr/local/cuda-10.0/lib64:/usr/lib:/usr/lib64:/usr/local/lib

git clone https://github.com/NVIDIA/apex.git
pushd apex
git checkout 37cdaf4
pip install -v --no-cache-dir --global-option="--cpp_ext" --global-option="--cuda_ext" ./
popd

git submodule init; git submodule update
pushd monotonic_align; python3.7 setup.py build_ext --inplace; popd

python3.7 reconfigure.py --speaker_dir ${model_name}

echo "done"

