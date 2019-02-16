# No shebang here.  Usage:
# ruby -I lib benchmark/mwm_general/dense_graphs/benchmark.rb

require 'benchmark'
require 'graph_matching'

COMPLETENESS = 0.1
MIN_SIZE = 2
MAX_SIZE = 300

$stdout.sync = true

# `completeness` - decimal percentage of vertexes each vertex
# is connected to.
def incomplete_graph(n, completeness)
  g = GraphMatching::Graph::WeightedGraph.new
  0.upto(n - 1) do |i| g.add_vertex(i) end
  max_weight = ((1..n - 1).reduce(:+).to_f * completeness).to_i + 1
  0.upto(n - 2) do |i|
    (i + 1).upto(n - 1) do |j|
      next unless rand < completeness
      g.add_edge(i, j)
      w = rand(max_weight)
      g.set_w([i, j], w)
    end
  end
  g
end

MIN_SIZE.upto(MAX_SIZE) do |v|
  print format("%5d\t", v)
  g = incomplete_graph(v, COMPLETENESS)
  GC.disable
  puts(Benchmark.realtime { g.maximum_weighted_matching(true) })
  GC.enable
end
