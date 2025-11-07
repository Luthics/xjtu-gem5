FROM ghcr.io/gem5/ubuntu-24.04_all-dependencies:v24-1

# Install python3-pip
RUN apt-get update && apt-get install -y python3-pip && apt-get clean

# Set working directory
WORKDIR /workspace