set title "MCM in Complete Bigraph is O(e * v)"
set key left
set term png size 800, 500
set output "~/git/jaredbeck/graph_matching/benchmark/mcm_bipartite/complete_bigraphs/plot.gnuplot"

set linetype 1 pointtype 7
set linetype 2 linewidth 3

set ytics autofreq tc lt 1
set ylabel 'Time (s)' tc lt 1
set y2tics autofreq tc lt 2
set y2label 'Edges * Vertexes' tc lt 2

plot "~/git/jaredbeck/graph_matching/benchmark/mcm_bipartite/complete_bigraphs/plot_data.txt" \
using 1:2 title "Time (s)" lt 1 axes x1y1, \
"" using 1:3 title "Edges * Vertexes" with lines lt 2 axes x1y2
