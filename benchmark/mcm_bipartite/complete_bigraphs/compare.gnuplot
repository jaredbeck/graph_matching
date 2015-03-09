data_dir = "~/git/jaredbeck/graph_matching/benchmark/mcm_bipartite/complete_bigraphs"

set title "MCM in Complete Bigraph"
set key left box
set term png size 800, 500
set output data_dir."/plot_compare.png"

set linetype 1 pointtype 7 linecolor rgb "#FF0000"
set linetype 2 pointtype 7 linecolor rgb "#00B800"

set xlabel 'Number of Vertexes (n)' tc lt 1
set ytics autofreq tc lt 1
set ylabel 'Time (s)' tc lt 1

plot \
data_dir."/time.data" \
using 1:2 title "Before" lt 1 axes x1y1, \
data_dir."/time2.data" \
using 1:2 title "After" lt 2 axes x1y1
