#!/bin/bash
# Run the Idris2 comprehensive benchmark
# Usage: ./run-benchmark.sh [--fresh|--cached]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BENCH_DIR="$SCRIPT_DIR"

# Check if idris2-docker is available
if command -v idris2-docker &>/dev/null; then
    RUNNER="idris2-docker"
elif [ -f "$HOME/bin/idris2-docker" ]; then
    RUNNER="$HOME/bin/idris2-docker"
else
    echo "Error: idris2-docker not found"
    echo "Download from: https://github.com/Oichkatzelesfrettschen/idris2-pack-docker"
    exit 1
fi

MODE="${1:---fresh}"

echo "=== Idris2 Benchmark Runner ==="
echo "Runner: $RUNNER"
echo "Mode: $MODE"
echo ""

# Export workspace
export IDRIS_WORKSPACE="$BENCH_DIR"

# Clean previous build
rm -rf "$BENCH_DIR/build"

echo "=== Compiling Benchmark ==="
time $RUNNER $MODE bash -c "cd /workspace && idris2 MathBench.idr -o mathbench"

echo ""
echo "=== Running Benchmark ==="
$RUNNER $MODE bash -c "cd /workspace && ./build/exec/mathbench"
