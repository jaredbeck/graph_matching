# frozen_string_literal: true

# No shebang here.  Usage:
# ruby -I lib benchmark/mwm_bipartite/misc/calc_d2/benchmark.rb

require 'benchmark'
require 'graph_matching'

$stdout.sync = true

# complete bigraph with three vertexes
g = GraphMatching::Graph::WeightedBigraph[
  [1, 2, 1],
  [1, 3, 2]
]
dogs, cats = g.partition

a = GraphMatching::Algorithm::MWMBipartite.new(g)
u = a.send(:init_duals, cats, dogs)
t = Set.new
s = Set.new(dogs)

GC.disable
puts(Benchmark.realtime { 100_000.times { a.send(:calc_d2, s, t, u) } })
GC.enable
