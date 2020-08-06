#!/bin/bash
# Simple automation of glow-tts training routines
# Meant to run on deployed boxes, eg. LambdaLabs
# This could also be a Dockerfile...

set -euxo pipefail

# Model name is a string identifier in [a-z\-]
model_name=${1}

mkdir -p /home/ubuntu/data
mkdir -p /home/ubuntu/code

sudo apt-get install \
  -y \
  build-essential \
  libffi-dev \
  libsndfile1 \
  libssl-dev \
  python-dev \
  python3-dev \
  python3-venv \
  silversearcher-ag

cd /home/ubuntu/code
git clone https://github.com/ml-applications/glow-tts.git

code_dir="glow-tts-${model_name}/"

mv "glow-tts/" "${code_dir}"
cd "${code_dir}"

# Make sure the repo is in its final directory location, otherwise venv hates you
python3 -m venv python
source python/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

git clone https://github.com/NVIDIA/apex.git
pushd apex
git checkout 37cdaf4
pip install -v --no-cache-dir --global-option="--cpp_ext" --global-option="--cuda_ext" ./
popd

git submodule init; git submodule update
pushd monotonic_align; python setup.py build_ext --inplace; popd

python reconfigure.py --speaker_dir ${model_name}

echo "done"

