data_dir = "~/git/jaredbeck/graph_matching/benchmark/mwm_bipartite/complete_bigraphs"

set title "MWM in Complete Bigraph is O(n ** (3/4) m log N)"
set key left box
set term png size 800, 500
set output data_dir."/plot.png"

set linetype 1 pointtype 7 linecolor rgb "#FF0000"
set linetype 2 linewidth 3 linecolor rgb "#00B800"

set xlabel 'Number of Vertexes (n)' tc lt 1
set ytics autofreq tc lt 1
set ylabel 'Time (s)' tc lt 1
set y2tics autofreq tc lt 2
set y2label 'n ** (3/4) m log N' tc lt 2

plot \
data_dir."/time.data" every 1:1:1::449 \
using 1:2 title "Time (s)" lt 1 axes x1y1, \
data_dir."/nmN.data" every 1:1:1::449 \
using 1:8 title "n ** (3/4) m log N" with lines lt 2 axes x1y2
