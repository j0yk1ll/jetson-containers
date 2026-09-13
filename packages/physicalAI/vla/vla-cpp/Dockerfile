#---
# name: vla-cpp
# group: robots
# docs: docs.md
# depends: [cuda, cmake]
# requires: '>=36'
# test: test.sh
#---

ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ARG VLA_CPP_REPO=https://github.com/VinRobotics/vla.cpp
ARG VLA_CPP_REF=main
ARG VLA_CPP_BUILD_TYPE=Release
ARG VLA_CPP_CMAKE_GENERATOR=Ninja
ARG VLA_CPP_BUILD_JOBS=0
ARG VLA_CPP_CUDA_ARCHITECTURES=87

ENV DEBIAN_FRONTEND=noninteractive
ENV VLA_CPP_HOME=/opt/vla.cpp
ENV VLA_CPP_BUILD=/opt/vla.cpp/build
ENV VLA_CACHE=/data/models/vla-cache

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        build-essential \
        ninja-build \
        pkg-config \
        ca-certificates \
        curl \
        libzmq3-dev \
        cppzmq-dev \
        libprotobuf-dev \
        protobuf-compiler \
        python3 \
        python3-pip \
        && rm -rf /var/lib/apt/lists/*

WORKDIR /opt

RUN git clone ${VLA_CPP_REPO} ${VLA_CPP_HOME} && \
    cd ${VLA_CPP_HOME} && \
    git fetch --tags --force && \
    git checkout ${VLA_CPP_REF} && \
    git rev-parse HEAD > /opt/vla-cpp.commit

WORKDIR ${VLA_CPP_HOME}

RUN set -eux; \
    if [ "${VLA_CPP_BUILD_JOBS}" = "0" ]; then JOBS="$(nproc)"; else JOBS="${VLA_CPP_BUILD_JOBS}"; fi; \
    cmake -S . -B ${VLA_CPP_BUILD} \
        -G "${VLA_CPP_CMAKE_GENERATOR}" \
        -DGGML_CUDA=ON \
        -DCMAKE_BUILD_TYPE=${VLA_CPP_BUILD_TYPE} \
        -DCMAKE_CUDA_ARCHITECTURES=${VLA_CPP_CUDA_ARCHITECTURES}; \
    cmake --build ${VLA_CPP_BUILD} -j"${JOBS}"

ENV PATH="${VLA_CPP_BUILD}:${PATH}"

COPY test.sh /opt/vla-cpp-tools/test.sh
RUN chmod +x /opt/vla-cpp-tools/test.sh

WORKDIR ${VLA_CPP_HOME}
CMD ["/bin/bash"]
