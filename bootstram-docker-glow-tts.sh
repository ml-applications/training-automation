# Do the initial install steps that only have to happen once.
set -euxo pipefail

# Create this so we can begin uploading training data.
mkdir -p /home/ubuntu/mount/training_data

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

# TODO: Need a way of doing this once and only once, in a non-destructive way.
sudo systemctl restart docker

