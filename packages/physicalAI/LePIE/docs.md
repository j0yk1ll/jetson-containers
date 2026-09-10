# LePIE

CUDA-enabled package for the `j0yk1ll/LePIE` VLA runtime on NVIDIA Jetson.

- Requires L4T/JetPack `>=36`
- Builds LePIE with `GGML_CUDA=ON`
- Keeps models outside the image
- Avoids PyTorch/JAX/OpenPI runtime dependencies
- Includes a smoke test and baseline benchmark harness

For reproducible benchmarking, pin `LEPIE_REF` to a commit SHA.
