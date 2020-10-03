#!/bin/bash
# Simple automation of glow-tts training routines

set -euxo pipefail

# Model name is a string identifier in [a-z\-]
model_name=${1}

# Current artifact
docker_tag="816a02c09b05"

docker_image="glow-tts-docker:${docker_tag}"

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
  --rm \
  --init \
  --ipc=host \
  --gpus all \
  ghcr.io/ml-applications/glow-tts-docker:${docker_tag}

