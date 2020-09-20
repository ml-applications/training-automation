#!/bin/bash
# Simple automation of glow-tts training routines

set -euxo pipefail

# Model name is a string identifier in [a-z\-]
model_name=${1}

# Current artifact
docker_tag="6a7f8a67800f"

docker_image="glow-tts-docker:${docker_tag}"

mkdir -p /home/ubuntu/mount
mkdir -p /home/ubuntu/code

sudo apt-get install \
  -y \
  docker \
  docker.io \
  ripgrep \
  silversearcher-ag

# Docker permissions
sudo groupadd -f docker

# Add current user to the docker group
sudo usermod -aG docker ${USER}

# Reevaluate group membership
#su -s ${USER}

# Fix docker runtime wrt GPUs
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)

curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -

curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list \
  | sudo tee /etc/apt/sources.list.d/nvidia-docker.list


sudo apt-get update
sudo apt-get install -y nvidia-docker2
sudo systemctl restart docker

docker pull ghcr.io/ml-applications/${docker_image}

docker volume create \
  --driver local \
  --opt type=none \
  --opt device=/home/ubuntu/mount \
  --opt o=bind \
  glow_tts_volume

docker run \
  --mount 'type=volume,src=glow_tts_volume,dst=/mount' \
  -e MOUNT_DIR=/mount \
  -e VOICE=${model_name} \
  -e PRETRAINED_MODEL_DESTINATION_FILENAME=${PRETRAINED_MODEL_DESTINATION_FILENAME} \
  -e PRETRAINED_MODEL_SOURCE_URL=${PRETRAINED_MODEL_SOURCE_URL} \
  -e ARPABET_SOURCE_URL=${ARPABET_SOURCE_URL} \
  --rm ghcr.io/ml-applications/glow-tts-docker:${docker_tag}

