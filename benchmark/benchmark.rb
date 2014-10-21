# No shebang here.  Usage:
# ruby -I lib benchmark/benchmark.rb

require 'benchmark'
require 'graph_matching'

MAX_SIZE = 1_000

def complete_graph(n)
  g = GraphMatching::Graph.new
  1.upto(n - 1) do |i|
    (i + 1).upto(n) do |j|
      g.add_edge(i, j)
    end
  end
  g
end

1.upto(MAX_SIZE) do |v|
  print "%5d\t" % [v]
  g = complete_graph(v)
  puts Benchmark.measure { g.maximum_cardinality_matching }
end
