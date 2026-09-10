# LePIE (`jetson-containers` package)

First-class `jetson-containers` package for `j0yk1ll/LePIE`.

## Build

```bash
jetson-containers build LePIE
```

Pin a specific source revision:

```bash
LEPIE_REF=<branch-tag-or-commit> jetson-containers build LePIE
```

## Run

```bash
jetson-containers run $(autotag LePIE)
```

## Start π0.5

```bash
PI_MODEL=pi05 llama-server \
  -m /data/models/pi05/pi05.gguf \
  --mmproj /data/models/pi05/mmproj-pi05.gguf \
  -ngl 99 \
  --host 0.0.0.0 \
  --port 8080
```

## Benchmark

```bash
MODEL=/data/models/pi05/pi05.gguf \
MMPROJ=/data/models/pi05/mmproj-pi05.gguf \
IMAGE1=/data/bench/view1.png \
IMAGE2=/data/bench/view2.png \
STATE="0,0,0,0,0,0,0,0" \
PROMPT="pick up the object and place it into the tray" \
WARMUP=3 \
RUNS=20 \
/opt/lepie-tools/benchmark.sh
```

Results are written under `/data/lepie-benchmarks/<timestamp>/`.

The image records the resolved LePIE source revision in `/opt/lepie.commit`.
