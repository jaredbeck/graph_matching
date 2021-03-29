require 'graph_matching'
#
# example with non consequtive vertices
#
edges=[[1, 2, 10],
  [1, 4, 11]
]
g = GraphMatching::Graph::WeightedBigraph[*edges]
m = g.maximum_weighted_matching
p m.edges
p m.weight(g)
