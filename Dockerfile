FROM ghcr.io/gem5/ubuntu-24.04_all-dependencies:v24-1

# Install python3-pip and ccache for build acceleration
RUN apt-get update && apt-get install -y python3-pip ccache && apt-get clean

# Set up ccache configuration
ENV CCACHE_DIR=/workspace/.ccache
ENV CCACHE_MAXSIZE=5G
ENV CCACHE_COMPRESS=1
ENV CCACHE_COMPRESSLEVEL=6
ENV PATH=/usr/local/bin:$PATH

# Create ccache directory (will be mounted as cache in CI)
# Note: In Docker BuildKit, use --mount=type=cache for persistence
RUN mkdir -p $CCACHE_DIR

# Set working directory
WORKDIR /workspace

# Clone gem5 repository
RUN git clone https://github.com/gem5/gem5

# Change to gem5 directory
WORKDIR /workspace/gem5

# Checkout specific commit
RUN git checkout e9da8d67bdbb23fbd0578a379f08f42bce50121d

# Modify build_opts/RISCV: change PROTOCOL from 'MI_example' to "MESI_Two_Level"
RUN sed -i "s/PROTOCOL = 'MI_example'/PROTOCOL = \"MESI_Two_Level\"/" build_opts/RISCV

# Check available compilers and ccache setup
RUN which gcc && which g++ && which ccache && ccache --version

# Configure ccache symlinks for automatic usage
RUN ln -sf /usr/bin/ccache /usr/local/bin/gcc && \
    ln -sf /usr/bin/ccache /usr/local/bin/g++ && \
    ln -sf /usr/bin/ccache /usr/local/bin/cc && \
    ln -sf /usr/bin/ccache /usr/local/bin/c++

# Build gem5 with ALL configuration using parallel jobs
# Using nproc to determine number of CPU cores for parallel build
# Note: For cache persistence, use: --mount=type=cache,target=/workspace/.ccache
RUN --mount=type=cache,target=/workspace/.ccache \
    scons build/RISCV/gem5.opt -j $(nproc)

# Try to execute the built gem5 binary
RUN ./build/RISCV/gem5.opt --help || true

# Create symlink for gem5 executable (gem5 -> gem5.opt)
RUN ln -sf build/RISCV/gem5.opt gem5

# Show ccache statistics after build
RUN --mount=type=cache,target=/workspace/.ccache \
    ccache -s || true

# Clone gem5_assignment repository
WORKDIR /workspace
RUN git clone https://github.com/Luthics/gem5_assignment.git gem5_assignment