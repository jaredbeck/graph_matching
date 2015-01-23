# encoding: utf-8

# No shebang here.  Usage:
# ruby -I lib benchmark/mwm_bipartite/complete_bigraphs/benchmark.rb

require 'benchmark'
require 'graph_matching'

MIN_SIZE = 2
MAX_SIZE = 300

$stdout.sync = true

# Returns a bipartite graph that is:
#
# 1. Complete - Each vertex in U has an edge to each vertex in V
# 2. Weighted - Each edge has a different, consecutive integer weight
# 3. "Balanced" - In an even bigraph, U and V have the same number of
#    vertexes.  In an odd bigraph, U has one more than V.
#    0 <= abs(U - V) <= 1
#
def complete_weighted_bigraph(n)
  g = GraphMatching::Graph::WeightedBigraph.new
  max_u = (n.to_f / 2).ceil
  min_v = max_u + 1
  weight = 1
  1.upto(max_u) do |i|
    min_v.upto(n) do |j|
      g.add_edge(i, j)
      g.set_w([i, j], weight)
      weight += 1
    end
  end
  g
end

MIN_SIZE.upto(MAX_SIZE) do |v|
  print "%5d\t" % [v]
  g = complete_weighted_bigraph(v)
  GC.disable
  puts Benchmark.realtime { g.maximum_weighted_matching }
  GC.enable
end
