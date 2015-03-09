#!/usr/bin/env bash

BENCHMARK_DIR='benchmark/mcm_bipartite/complete_bigraphs'

if [ ! -d "$BENCHMARK_DIR" ]; then
  echo "Directory not found: $BENCHMARK_DIR" 1>&2
  exit 1
fi

echo "Benchmarking .."
ruby -I lib "$BENCHMARK_DIR/benchmark.rb" > "$BENCHMARK_DIR/time2.data"

echo "Plotting .."
gnuplot "$BENCHMARK_DIR/compare.gnuplot"
open "$BENCHMARK_DIR/plot_compare.png"
