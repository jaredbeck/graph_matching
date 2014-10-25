set title "MCM in Complete Graph"
set key left
set term png size 800, 500
set output "/Users/jared/git/jaredbeck/graph_matching/benchmark/mcm_general/complete_graphs/plot.png"

set xlabel 'Number of Vertexes' tc lt 1
set ylabel 'Time (s)' tc lt 1

plot "/Users/jared/git/jaredbeck/graph_matching/benchmark/mcm_general/complete_graphs/plot_data.txt" \
using 1:2 with lines title "Time (s)" lt 1
