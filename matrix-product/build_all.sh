#!/usr/bin/env bash
# Combos:
#   RR : A row‑major (Right), B row‑major (Right)
#   RL : A row‑major (Right), B column‑major (Left)
#   LR : A column‑major (Left), B row‑major (Right)
#   LL : A column‑major (Left), B column‑major (Left)
# Each build is generated in its own directory (build-rr, build-rl, …).
# Usage: ./build_all.sh [--gemm] [--block [BS]] [--jobs|-j [N]] [--clean]
#   --gemm         : only GEMM build (skip naive)
#   --block [SIZE] : also build/cache‑blocked kernel with optional block size (default 32)
#   --jobs|-j [N]  : limit compile parallelism to N (default half of cpu cores)
#   --clean        : remove build directories unconditionally

set -euo pipefail

COMBOS=(
  "RR Right Right"
  "RL Right Left"
  "LR Left  Right"
  "LL Left  Left"
)

GEMM_ONLY=false
BUILD_BLOCK=false
BLOCK_SIZE=32
JOBS="auto"          # use all/half cores unless overridden
CLEAN_BUILD=false

# ---------------- parse CLI ----------------
while [[ $# -gt 0 ]]; do
  case $1 in
    --gemm)
      GEMM_ONLY=true
      shift ;;
    --block)
      BUILD_BLOCK=true
      shift
      if [[ $# -gt 0 && $1 != --* ]]; then
        BLOCK_SIZE=$1
        shift
      fi ;;
    --jobs|-j)
      shift
      JOBS=${1:?"--jobs requires a number"}
      shift ;;
    --clean)
      CLEAN_BUILD=true ; shift ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# determine default parallelism
if [[ $JOBS == auto ]]; then
  total=$(sysctl -n hw.ncpu 2>/dev/null || nproc || echo 4)
  JOBS=$(( total/2 ))
  (( JOBS<1 )) && JOBS=1
fi

for combo in "${COMBOS[@]}"; do
  read -r TAG LA LB <<< "$combo"

  # ---------- GEMM build ----------
  BUILD_DIR="build-${TAG,,}" 
  echo "=== Building GEMM $TAG (A=$LA, B=$LB) ==="
  $CLEAN_BUILD && rm -rf "$BUILD_DIR"
  cmake -B "$BUILD_DIR" -DCMAKE_BUILD_TYPE=Release \
        -DKokkos_ENABLE_OPENMP=ON \
        -DCMAKE_CXX_FLAGS="-DLAYOUT_A=$LA -DLAYOUT_B=$LB"
  cmake --build "$BUILD_DIR" --parallel "$JOBS"
  echo

  # Run benchmark for GEMM
  M=${M:-2000} N=${N:-2000} K=${K:-2000}
  CSV="results_${TAG}_gemm.csv"
  echo "Running benchmark (GEMM) → $CSV"
  python3 benchmark/measure_perf.py "$M" "$N" "$K" \
         --exe "$BUILD_DIR/src/top.matrix_product" \
         --csv "$CSV"
  echo

  # --------- Naive build ----------
  if ! $GEMM_ONLY; then
    BUILD_DIR_N="build-${TAG,,}-naive"
    echo "=== Building NAIVE $TAG (A=$LA, B=$LB) ==="
    $CLEAN_BUILD && rm -rf "$BUILD_DIR_N"
    cmake -B "$BUILD_DIR_N" -DCMAKE_BUILD_TYPE=Release \
          -DKokkos_ENABLE_OPENMP=ON \
          -DCMAKE_CXX_FLAGS="-DUSE_NAIVE -DLAYOUT_A=$LA -DLAYOUT_B=$LB"
    cmake --build "$BUILD_DIR_N" --parallel "$JOBS"
    echo

    CSV_N="results_${TAG}_naive.csv"
    echo "Running benchmark (NAIVE) → $CSV_N"
    python3 benchmark/measure_perf.py "$M" "$N" "$K" \
           --exe "$BUILD_DIR_N/src/top.matrix_product" \
           --csv "$CSV_N"
    echo
  fi

  echo

  # ----------- Blocked build ----------
  if $BUILD_BLOCK; then
    BS=${BLOCK_SIZE:-32}
    BUILD_DIR_B="build-${TAG,,}-blocked"
    echo "=== Building BLOCKED $TAG (A=$LA, B=$LB, BS=$BS) ==="
    $CLEAN_BUILD && rm -rf "$BUILD_DIR_B"
    cmake -B "$BUILD_DIR_B" -DCMAKE_BUILD_TYPE=Release \
          -DKokkos_ENABLE_OPENMP=ON \
          -DCMAKE_CXX_FLAGS="-DUSE_BLOCK -DLAYOUT_A=$LA -DLAYOUT_B=$LB -DBLOCK_SIZE=$BS"
    cmake --build "$BUILD_DIR_B" --parallel "$JOBS"
    echo

    CSV_B="results_${TAG}_blocked.csv"
    echo "Running benchmark (BLOCKED) → $CSV_B"
    python3 benchmark/measure_perf.py "$M" "$N" "$K" \
           --exe "$BUILD_DIR_B/src/top.matrix_product" \
           --csv "$CSV_B"
    echo
  fi
done

echo "All builds and benchmarks completed."
