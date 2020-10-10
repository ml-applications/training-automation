#!/bin/bash
# Simple automation of melgan-seungwonpark training routines

set -euxo pipefail

# Model name is a string identifier in [a-z\-]
model_name=${1}

# Current artifact
# https://github.com/orgs/ml-applications/packages/container/package/melgan-seungwonpark-docker
docker_tag="528f73d133db"

docker_image="melgan-seungwonpark-docker:${docker_tag}"

docker pull ghcr.io/ml-applications/${docker_image}

docker volume create \
  --driver local \
  --opt type=none \
  --opt device=/home/ubuntu/mount \
  --opt o=bind \
  melgan_volume

docker run \
  --mount 'type=volume,src=melgan_volume,dst=/mount' \
  -e MOUNT_DIR=/mount \
  -e VOICE=${model_name} \
  -e PRETRAINED_MODEL_DESTINATION_FILENAME=${PRETRAINED_MODEL_DESTINATION_FILENAME} \
  -e PRETRAINED_MODEL_SOURCE_URL=${PRETRAINED_MODEL_SOURCE_URL} \
  --rm \
  --init \
  --ipc=host \
  --gpus all \
  ghcr.io/ml-applications/melgan-seungwonpark-docker:${docker_tag}

