#---
# name: lepie
# group: robots
# docs: docs.md
# depends: [cuda, cmake]
# buildkit_device: nvidia.com/gpu=all
# requires: '>=36'
# test: test.sh
#---

ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ARG LEPIE_REPO=https://github.com/j0yk1ll/LePIE
ARG LEPIE_REF=master
ARG LEPIE_BUILD_TYPE=Release
ARG LEPIE_CMAKE_GENERATOR=Ninja
ARG LEPIE_BUILD_JOBS=0

ENV DEBIAN_FRONTEND=noninteractive
ENV LEPIE_HOME=/opt/lepie
ENV LEPIE_BUILD=/opt/lepie/build
ENV PI_MODEL=auto

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        build-essential \
        ninja-build \
        pkg-config \
        ca-certificates \
        curl \
        libcurl4-openssl-dev \
        && rm -rf /var/lib/apt/lists/*

WORKDIR /opt

RUN git clone ${LEPIE_REPO} ${LEPIE_HOME} && \
    cd ${LEPIE_HOME} && \
    git fetch --tags --force && \
    git checkout ${LEPIE_REF} && \
    git submodule update --init --recursive && \
    git rev-parse HEAD > /opt/lepie.commit

WORKDIR ${LEPIE_HOME}

RUN set -eux; \
    if [ "${LEPIE_BUILD_JOBS}" = "0" ]; then JOBS="$(nproc)"; else JOBS="${LEPIE_BUILD_JOBS}"; fi; \
    cmake -S . -B ${LEPIE_BUILD} \
        -G "${LEPIE_CMAKE_GENERATOR}" \
        -DGGML_CUDA=ON \
        -DCMAKE_BUILD_TYPE=${LEPIE_BUILD_TYPE}; \
    cmake --build ${LEPIE_BUILD} --target llama-server -j"${JOBS}"

ENV PATH="${LEPIE_BUILD}/bin:${PATH}"

COPY test.sh /opt/lepie-tools/test.sh
COPY benchmark.sh /opt/lepie-tools/benchmark.sh
COPY benchmark.py /opt/lepie-tools/benchmark.py

RUN chmod +x /opt/lepie-tools/test.sh /opt/lepie-tools/benchmark.sh /opt/lepie-tools/benchmark.py

WORKDIR ${LEPIE_HOME}
CMD ["/bin/bash"]
