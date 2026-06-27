#!/bin/bash

sudo apt install -y \
    cmake \
    libncurses5-dev \
    libncursesw5-dev \
    libdrm-dev \
    libsystemd-dev \
    pkg-config

git clone https://github.com/Syllo/nvtop.git
cd nvtop/ || exit
mkdir -p build && cd build || exit
cmake .. -DENABLE_INTEL=ON -DENABLE_NVIDIA=OFF -DENABLE_AMDGPU=OFF
make -j"$(nproc)"
sudo make install