#!/bin/bash

set -e


CUDA_PATH="${HOME}/cuda.run"
TORCH_WHL="torch-1.2.0-cp36-cp36m-manylinux1_x86_64.whl"
TORCH_PATH="${HOME}/${TORCH_WHL}"
TORCHVISION_WHL="torchvision-0.4.0-cp36-cp36m-manylinux1_x86_64.whl"
TORCHVISION_PATH="${HOME}/${TORCHVISION_WHL}"
VIRTUALENV_PATH="${HOME}/venv"

function install_cuda() {
    CUDA_URL="https://developer.nvidia.com/compute/cuda/10.0/Prod/local_installers/cuda_10.0.130_410.48_linux"
    if [ ! -f $CUDA_PATH ]; then
	wget $CUDA_URL -O ${HOME}/cuda.run;
    fi
    if [ ! -d "/usr/local/cuda-10.0/" ]; then
       sudo sh $CUDA_PATH --silent --toolkit --override;
    fi
}

function create_virtualenv() {
    virtualenv -p python3.6 $VIRTUALENV_PATH
}

function download_torch() {
    TORCH_URL="https://download.pytorch.org/whl/cu100/${TORCH_WHL}"
    TORCHVISION_URL="https://download.pytorch.org/whl/cu100/${TORCHVISION_WHL}"
    if [ ! -f $TORCH_PATH ]; then
	wget $TORCH_URL -O $TORCH_PATH
    fi
    if [ ! -f $TORCHVISION_PATH ]; then
	wget $TORCHVISION_URL -O $TORCHVISION_PATH
    fi
}

function install_torch() {
    . $VIRTUALENV_PATH/bin/activate
    pip install $TORCH_PATH 
    pip install $TORCHVISION_PATH
}

function setup_pyenv() {
    if [ ! -d "/home/ubuntu/.pyenv" ]; then
	BASHRC_PATH=/home/ubuntu/.bashrc
	sudo apt-get install -y build-essential libssl-dev zlib1g-dev libbz2-dev \
	     libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
	     xz-utils tk-dev libffi-dev liblzma-dev python-openssl git
	curl https://pyenv.run | bash
	LINE_1='export PATH="/home/ubuntu/.pyenv/bin:$PATH"'
	LINE_2='eval "$(pyenv init -)"'
	LINE_3='eval "$(pyenv virtualenv-init -)"'
	grep -qxF "$LINE_1" $BASHRC_PATH || echo $LINE_1 >> $BASHRC_PATH
	grep -qxF "$LINE_2" $BASHRC_PATH || echo $LINE_2 >> $BASHRC_PATH
	grep -qxF "$LINE_3" $BASHRC_PATH || echo $LINE_3 >> $BASHRC_PATH

	export PATH="/home/ubuntu/.pyenv/bin:$PATH"
	eval "$(pyenv init -)"
	eval "$(pyenv virtualenv-init -)"
	pyenv install 3.6.9
	pyenv global 3.6.9
    fi
}

install_cuda;
setup_pyenv;
create_virtualenv;
download_torch;
install_torch;
