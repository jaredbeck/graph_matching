GraphMatching
=============

Finds maximum [matchings][6] in undirected [graphs][7].

Implements modern algorithms for finding maximum cardinality
and maximum weighted matchings in undirected graphs and bigraphs.
Uses data structures and traversal algorithms from the
[Ruby Graph Library (RGL)][4].

Algorithms
----------

### Maximum Cardinality Matching in Bipartite Graph

Uses the [Augmenting Path][5] algorithm.

```ruby
require 'graph_matching'
g = GraphMatching::BipartiteGraph.new
g.add_edge('alice', 'bob')
g.add_edge('christine', 'don')
g.maximum_cardinality_matching
#=> #<Set: {['alice', 'don'], ['christine', 'bob']}>
```

- Videos
    - [The Augmenting Path Algorithm for Bipartite Matching][1]
    - [The Augmenting Path Algorithm (Example)][2]

Glossary
--------

- [Bipartite Graph][3] (bigraph)
- [Graph][7]
- [Matching][6]

[1]: http://www.youtube.com/watch?v=ory4WMX0rDU "The Augmenting Path Algorithm for Bipartite Matching"
[2]: http://www.youtube.com/watch?v=C9c8zEZXboA "The Augmenting Path Algorithm (Example)"
[3]: http://en.wikipedia.org/wiki/Bipartite_graph
[4]: http://rgl.rubyforge.org/rgl/index.html
[5]: http://en.wikipedia.org/wiki/Matching_%28graph_theory%29#In_unweighted_bipartite_graphs
[6]: http://en.wikipedia.org/wiki/Matching_%28graph_theory%29
[7]: http://en.wikipedia.org/wiki/Graph_theory
