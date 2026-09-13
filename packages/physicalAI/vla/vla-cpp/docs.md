# vla.cpp

Native C++/GGML inference for Vision-Language-Action models on Jetson, using [VinRobotics/vla.cpp](https://github.com/VinRobotics/vla.cpp).

The package builds the CUDA backend for Jetson Orin (`sm_87`) and provides `vla-cli`, `vla-server`, and `vla-bench`.  vla.cpp packages supported policies as self-contained GGUF files and supports models including SmolVLA, Evo-1, and VLA-Adapter.

## Build

```bash
jetson-containers build vla-cpp
```

The default CUDA architecture is `87` for Jetson Orin Nano/NX.  Override `VLA_CPP_REF` or `VLA_CPP_CUDA_ARCHITECTURES` as build arguments when testing another revision or target.

## Run

Mount a persistent model/cache directory when running the container.  For example:

```bash
jetson-containers run --volume /data/models:/data/models $(autotag vla-cpp)
```

Inside the container, a local GGUF can be smoke-tested with:

```bash
vla-cli --ckpt /data/models/model.gguf \
    --image /path/to/front.jpg \
    --text "pick up the black bowl" \
    --pretty
```

Start the long-running inference server with:

```bash
vla-server /data/models/model.gguf
```

The server binds ZeroMQ on `tcp://*:5555` by default.

## Benchmark

`vla-bench` measures in-process model inference without simulator or transport overhead:

```bash
vla-bench --ckpt /data/models/model.gguf --images 1 --size 224 --markdown
```

For LIBERO task-success evaluation, use the evaluation clients and simulator setup in the upstream vla.cpp repository.  Keep simulator-side and policy-side measurements separate when comparing Jetson latency and memory use.
