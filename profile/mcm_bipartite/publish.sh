#!/usr/bin/env bash

BENCHMARK_DIR='benchmark/mcm_bipartite/complete_bigraphs'

if [ ! -d "$BENCHMARK_DIR" ]; then
  echo "Directory not found: $BENCHMARK_DIR" 1>&2
  exit 1
fi

rm "$BENCHMARK_DIR/plot_compare.png"
mv "$BENCHMARK_DIR/time2.data" "$BENCHMARK_DIR/time.data"
gnuplot "$BENCHMARK_DIR/plot.gnuplot"
