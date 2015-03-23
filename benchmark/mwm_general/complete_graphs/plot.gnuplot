data_dir = "~/git/jaredbeck/graph_matching/benchmark/mwm_general/complete_graphs"

set title "MWM Should Be O(ev log v) In General Graphs\n".\
"(Galil, 1986, p. 34)"
set key left box
set term png size 800, 500
set output data_dir."/plot.png"

set linetype 1 pointtype 7 linecolor rgb "#FF0000"
set linetype 2 linewidth 3 linecolor rgb "#00B800"

set xlabel 'Number of Vertexes, v' textcolor rgb "black"
set ytics autofreq textcolor rgb "black"
set ylabel 'Time (s)' textcolor rgb "black"
set y2tics autofreq textcolor rgb "black"
set y2label 'ev log v' textcolor rgb "black"

plot \
data_dir."/time.data" every 1:1:1::299 \
using 1:2 title "Time (s)" lt 1 axes x1y1, \
data_dir."/mn_log_n.data" every 1:1:1::299 \
using 1:4 title "ev log v" with lines lt 2 axes x1y2
