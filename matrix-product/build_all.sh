#!/usr/bin/env bash
# Combos:
#   RR : A row‑major (Right), B row‑major (Right)
#   RL : A row‑major (Right), B column‑major (Left)
#   LR : A column‑major (Left), B row‑major (Right)
#   LL : A column‑major (Left), B column‑major (Left)
# Each build is generated in its own directory (build-rr, build-rl, …).

set -euo pipefail

COMBOS=(
  "RR Right Right"
  "RL Right Left"
  "LR Left  Right"
  "LL Left  Left"
)

for combo in "${COMBOS[@]}"; do
  read -r TAG LA LB <<< "$combo"
  BUILD_DIR="build-${TAG,,}" 
  echo "=== Building $TAG (A=$LA, B=$LB) ==="
  cmake -B "$BUILD_DIR" -DCMAKE_BUILD_TYPE=Release \
        -DKokkos_ENABLE_OPENMP=ON \
        -DCMAKE_CXX_FLAGS="-DLAYOUT_A=$LA -DLAYOUT_B=$LB"
  cmake --build "$BUILD_DIR" -j
  echo

  # --- Run benchmark and append results ---
  M=${M:-2000} N=${N:-2000} K=${K:-2000}
  CSV="results_${TAG}.csv"
  echo "Running benchmark → $CSV"
  python benchmark/measure_perf.py "$M" "$N" "$K" \
         --exe "$BUILD_DIR/src/top.matrix_product" \
         --csv "$CSV"
  echo
done

echo "All builds and benchmarks completed."
