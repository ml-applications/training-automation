#!/bin/bash
# Simple automation of Melgan training routines
# Meant to run on deployed boxes, eg. LambdaLabs
# This could also be a Dockerfile...

set -euxo pipefail

model_name=${1}

mkdir -p /home/ubuntu/data
mkdir -p /home/ubuntu/code

cd /home/ubuntu/code
git clone https://github.com/ml-applications/melgan-seungwonpark.git

code_dir="melgan-seungwonpark-${model_name}/"

mv "melgan-seungwonpark/" "${code_dir}"
cd "${code_dir}"

# Make sure the repo is in its final directory location, otherwise venv hates you
python3 -m venv python
source python/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

