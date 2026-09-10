#!/usr/bin/env python3
import argparse
import json
import statistics
import time
import urllib.request

def call(url, prompt):
    body = json.dumps({"text": prompt}).encode("utf-8")
    req = urllib.request.Request(
        url,
        data=body,
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    t0 = time.perf_counter()
    with urllib.request.urlopen(req) as response:
        payload = response.read()
    wall_ms = (time.perf_counter() - t0) * 1000.0
    return wall_ms, json.loads(payload.decode("utf-8"))

def percentile(xs, p):
    ys = sorted(xs)
    if not ys:
        return None
    if len(ys) == 1:
        return ys[0]
    k = (len(ys)-1) * p
    lo = int(k)
    hi = min(lo+1, len(ys)-1)
    f = k-lo
    return ys[lo]*(1-f) + ys[hi]*f

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--url", required=True)
    ap.add_argument("--prompt", required=True)
    ap.add_argument("--warmup", type=int, default=3)
    ap.add_argument("--runs", type=int, default=10)
    ap.add_argument("--output", required=True)
    args = ap.parse_args()

    for i in range(args.warmup):
        wall, _ = call(args.url, args.prompt)
        print(f"warmup {i+1}/{args.warmup}: {wall:.2f} ms")

    rows = []
    for i in range(args.runs):
        wall, obj = call(args.url, args.prompt)
        row = {"run": i+1, "wall_ms": wall, "response": obj}
        for key in ("encode_ms", "decode_ms", "total_ms", "timing_breakdown_ms"):
            if key in obj:
                row[key] = obj[key]
        rows.append(row)
        st = obj.get("total_ms")
        extra = f", server={st:.2f} ms" if isinstance(st, (int,float)) else ""
        print(f"run {i+1}/{args.runs}: wall={wall:.2f} ms{extra}")

    wall = [r["wall_ms"] for r in rows]
    summary = {
        "runs": len(rows),
        "wall_ms": {
            "mean": statistics.mean(wall),
            "median": statistics.median(wall),
            "min": min(wall),
            "max": max(wall),
            "p90": percentile(wall, 0.90),
            "p95": percentile(wall, 0.95),
        },
    }
    for key in ("encode_ms", "decode_ms", "total_ms"):
        vals = [r[key] for r in rows if isinstance(r.get(key), (int,float))]
        if vals:
            summary[key] = {
                "mean": statistics.mean(vals),
                "median": statistics.median(vals),
                "min": min(vals),
                "max": max(vals),
                "p90": percentile(vals, 0.90),
                "p95": percentile(vals, 0.95),
            }

    with open(args.output, "w", encoding="utf-8") as f:
        json.dump({"summary": summary, "samples": rows}, f, indent=2)

    print(json.dumps(summary, indent=2))

if __name__ == "__main__":
    main()
