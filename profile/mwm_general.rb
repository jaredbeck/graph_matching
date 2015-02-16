# No shebang here.  Run with:
#
# ruby -I lib profile/mwm_general.rb

require 'graph_matching'
require 'ruby-prof'

def complete_graph(n)
  g = GraphMatching::Graph::WeightedGraph.new
  n_edges = (1 .. n - 1).reduce(:+)
  0.upto(n - 2) do |i|
    (i + 1).upto(n - 1) do |j|
      g.add_edge(i, j)
      g.set_w([i, j], rand(n_edges))
    end
  end
  g
end

g = complete_graph(100)
GC.disable
RubyProf.start
g.maximum_weighted_matching(true)
result = RubyProf.stop
GC.enable

printer = RubyProf::FlatPrinter.new(result)
printer.print(STDOUT)
