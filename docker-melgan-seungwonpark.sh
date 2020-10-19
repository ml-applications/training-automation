#!/bin/bash
# Simple automation of melgan-seungwonpark training routines

set -euxo pipefail

# Model name is a string identifier in [a-z\-]
model_name=${1}

# Optional mount path
#
# The mount path uses the following subdirectories:
#
#   ${MOUNT_DIR}/training_data/melgan_${VOICE} (training data must be here!)
#   ${MOUNT_DIR}/checkpoints/${VOICE} (output; auto-managed)
#   ${MOUNT_DIR}/shared (auto-managed)
#
# The mount path can be shared between training instances.
#
if [ -z ${2+x} ]; then
  host_mount_directory="/home/ubuntu/mount"
else
  host_mount_directory="${2}"
fi

echo "Model name: ${model_name}"
echo "Host mount directory: ${host_mount_directory}"

# Current artifact
# https://github.com/orgs/ml-applications/packages/container/package/melgan-seungwonpark-docker
docker_tag="8d8d4a9fabeb"

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
  -e DATE=${DATE} \
  --rm \
  --init \
  --ipc=host \
  --gpus all \
  ghcr.io/ml-applications/melgan-seungwonpark-docker:${docker_tag}

