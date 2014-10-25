set title "MCM in Complete Graph"
set key left
set term png size 800, 500
set output "~/Desktop/plot.png"

plot "~/git/jaredbeck/graph_matching/benchmark/plot/mcm_general/complete_graphs/plot_data.txt" \
using 1:2 with lines title "Time (s)" lt 1
