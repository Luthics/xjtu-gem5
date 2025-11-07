FROM ghcr.io/gem5/ubuntu-24.04_all-dependencies:v24-1

# Install python3-pip and ccache for build acceleration
RUN apt-get update && apt-get install -y python3-pip ccache && apt-get clean

# Set up ccache configuration
ENV CCACHE_DIR=/workspace/.ccache
ENV CCACHE_MAXSIZE=5G
ENV CCACHE_COMPRESS=1
ENV CCACHE_COMPRESSLEVEL=6
ENV PATH=/usr/local/bin:$PATH

# Create ccache directory
RUN mkdir -p $CCACHE_DIR

# Set working directory
WORKDIR /workspace

# Clone gem5 repository
RUN git clone https://github.com/gem5/gem5

# Change to gem5 directory
WORKDIR /workspace/gem5

# Check available compilers and ccache setup
RUN which gcc && which g++ && which ccache && ccache --version

# Configure ccache symlinks for automatic usage
RUN ln -sf /usr/bin/ccache /usr/local/bin/gcc && \
    ln -sf /usr/bin/ccache /usr/local/bin/g++ && \
    ln -sf /usr/bin/ccache /usr/local/bin/cc && \
    ln -sf /usr/bin/ccache /usr/local/bin/c++

# Build gem5 with ALL configuration using parallel jobs
# Using nproc to determine number of CPU cores for parallel build
RUN scons build/ALL/gem5.opt -j $(nproc)