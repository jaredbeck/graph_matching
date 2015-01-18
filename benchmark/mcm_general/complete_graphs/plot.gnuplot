data_dir = "~/git/jaredbeck/graph_matching/benchmark/mcm_general/complete_graphs"

set title "MCM in Complete Graph is O(v ^ 3)"
set key left
set term png size 800, 500
set output data_dir."/plot.png"

set linetype 1 pointtype 7 linecolor rgb "#FF0000"
set linetype 2 linewidth 3 linecolor rgb "#00B800"

set xlabel 'Number of Vertexes, V' tc lt 1
set ytics autofreq tc lt 1
set ylabel 'Time (s)' tc lt 1
set y2tics autofreq tc lt 2
set y2label 'V ^ 3' tc lt 2

plot data_dir."/time.data" using 1:2 title "Time (s)" lt 1, \
data_dir."/v_cubed.data" using 1:2 title "V ^ 3" with lines lt 2 axes x1y2
