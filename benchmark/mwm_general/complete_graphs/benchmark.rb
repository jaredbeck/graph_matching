# No shebang here.  Usage:
# ruby -I lib benchmark/mwm_general/complete_graphs/benchmark.rb

require 'benchmark'
require 'graph_matching'

MIN_SIZE = 2
MAX_SIZE = 300

$stdout.sync = true

def complete_graph(n)
  g = GraphMatching::Graph::WeightedGraph.new
  n_edges = (1..n - 1).reduce(:+)
  0.upto(n - 2) do |i|
    (i + 1).upto(n - 1) do |j|
      g.add_edge(i, j)
      g.set_w([i, j], rand(n_edges))
    end
  end
  g
end

MIN_SIZE.upto(MAX_SIZE) do |v|
  print format("%5d\t", v)
  g = complete_graph(v)
  GC.disable
  puts(Benchmark.realtime { g.maximum_weighted_matching(true) })
  GC.enable
end
