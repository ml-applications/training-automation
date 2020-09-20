#!/bin/bash
# Simple automation of glow-tts training routines

set -euxo pipefail

# Model name is a string identifier in [a-z\-]
model_name=${1}

# Current artifact
docker_image="glow-tts-docker:3fbafc9f3dd8"

mkdir -p /home/ubuntu/mount
mkdir -p /home/ubuntu/code

sudo apt-get install \
  -y \
  docker \
  docker.io \
  ripgrep \
  silversearcher-ag

# Docker permissions
if [ ! $(getent group admin) ]; then
  sudo groupadd docker
fi

# Add current user to the docker group
sudo usermod -aG docker ${USER}

# Reevaluate group membership
su -s ${USER}

docker pull docker.pkg.github.com/ml-applications/glow-tts-docker/${docker_image}

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
  --rm ${docker_image}

