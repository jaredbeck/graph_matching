# No shebang here.  Usage:
# ruby -I lib benchmark/mcm_bipartite/complete_bigraphs/benchmark.rb

require 'benchmark'
require 'graph_matching'

MIN_SIZE = 2
MAX_SIZE = 500

$stdout.sync = true

def complete_bigraph(n)
  g = GraphMatching::Graph::Bigraph.new
  max_u = (n.to_f / 2).ceil
  min_v = max_u + 1
  1.upto(max_u) do |i|
    min_v.upto(n) do |j|
      g.add_edge(i, j)
    end
  end
  g
end

MIN_SIZE.upto(MAX_SIZE) do |v|
  print "%5d\t" % [v]
  g = complete_bigraph(v)
  GC.disable
  puts Benchmark.realtime { g.maximum_cardinality_matching }
  GC.enable
end
