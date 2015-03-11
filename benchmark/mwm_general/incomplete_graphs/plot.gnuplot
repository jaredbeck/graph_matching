data_dir = "~/git/jaredbeck/graph_matching/benchmark/mwm_general/incomplete_graphs"

set title "MWM in Incomplete General Graphs"
set key left box
set term png size 800, 500
set output data_dir."/plot.png"

set linetype 1 pointtype 7 linecolor rgb "#FF0000"
set linetype 2 pointtype 7 linecolor rgb "#00B800"
set linetype 3 pointtype 7 linecolor rgb "#0000FF"

set xlabel 'Number of Vertexes (n)' tc lt 1
set ytics autofreq tc lt 1
set ylabel 'Time (s)' tc lt 1

plot \
data_dir."/time_30_pct.data" \
using 1:2 title "Time (s) 30% Completeness" lt 3, \
data_dir."/time_20_pct.data" \
using 1:2 title "Time (s) 20% Completeness" lt 2, \
data_dir."/time_10_pct.data" \
using 1:2 title "Time (s) 10% Completeness" lt 1
