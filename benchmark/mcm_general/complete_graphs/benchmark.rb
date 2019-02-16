# No shebang here.  Usage:
# ruby -I lib benchmark/mcm_general/complete_graphs/benchmark.rb

require 'benchmark'
require 'graph_matching'

MIN_SIZE = 2
MAX_SIZE = 500

$stdout.sync = true

def complete_graph(n)
  g = GraphMatching::Graph::Graph.new
  1.upto(n - 1) do |i|
    (i + 1).upto(n) do |j|
      g.add_edge(i, j)
    end
  end
  g
end

MIN_SIZE.upto(MAX_SIZE) do |v|
  print "%5d\t" % [v]
  g = complete_graph(v)
  GC.disable
  puts(Benchmark.realtime { g.maximum_cardinality_matching })
  GC.enable
end
