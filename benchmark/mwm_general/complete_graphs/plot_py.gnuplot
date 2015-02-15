data_dir = "~/git/jaredbeck/graph_matching/benchmark/mwm_general/complete_graphs"

set title "MWM in Ruby vs. Python"
set key left box
set term png size 800, 500
set output data_dir."/plot_py.png"

set linetype 1 pointtype 7 linecolor rgb "#FF0000"
set linetype 2 pointtype 7 linecolor rgb "#00B800"

set xlabel 'Number of Vertexes (n)' tc lt 1
set ytics autofreq tc lt 1
set ylabel 'Time (s)' tc lt 1

plot \
data_dir."/time.data" every 1:1:1::149 \
using 1:2 title "Time, Ruby 2.2.0 (s)" lt 1, \
data_dir."/time_py.data" every 1:1:1::149 \
using 1:2 title "Time, Python 2.7.6 (s)" lt 2
