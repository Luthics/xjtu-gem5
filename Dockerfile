FROM ghcr.io/gem5/ubuntu-24.04_all-dependencies:v24-1

# Install python3-pip and ccache for build acceleration
RUN apt-get update && apt-get install -y python3-pip ccache && apt-get clean

# Set up ccache configuration
ENV CCACHE_DIR=/workspace/.ccache
ENV CCACHE_MAXSIZE=5G
ENV CCACHE_COMPRESS=1
ENV CCACHE_COMPRESSLEVEL=6

# Create ccache directory
RUN mkdir -p $CCACHE_DIR

# Set working directory
WORKDIR /workspace

# Clone gem5 repository
RUN git clone https://github.com/gem5/gem5

# Change to gem5 directory
WORKDIR /workspace/gem5

# Build gem5 with ALL configuration using parallel jobs and ccache acceleration
# Using nproc to determine number of CPU cores for parallel build
RUN CC="ccache gcc" CXX="ccache g++" scons build/ALL/gem5.opt -j $(nproc)