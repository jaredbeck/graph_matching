GraphMatching
=============

Finds maximum [matchings][6] in undirected [graphs][7].

Implements modern algorithms for finding maximum cardinality
and maximum weighted matchings in undirected graphs and bigraphs.
Uses data structures and traversal algorithms from the
[Ruby Graph Library (RGL)][4].

Algorithms
----------

### Maximum Cardinality Matching in Bipartite Graphs

Uses the [Augmenting Path][5] algorithm.

```ruby
require 'graph_matching'
g = GraphMatching::BipartiteGraph[1,3, 1,4, 2,3, 2,4]
g.maximum_cardinality_matching # two maximum matchings
#=> #<GraphMatching::Matching: {[3, 1], [4, 2]}>
```

- Videos by [Derrick Stolee][8]
    - [The Augmenting Path Algorithm for Bipartite Matching][1]
    - [The Augmenting Path Algorithm (Example)][2]

### Maximum Cardinality Matching in General Graphs

Uses [Edmonds' Blossom][9] algorithm as described in
[Introduction to Graph Theory][10] (West, 2001, p. 142)

```ruby
require 'graph_matching'
g = GraphMatching::Graph[1,2, 1,3, 1,4, 2,3, 2,4, 3,4]
g.maximum_cardinality_matching # three maximum matchings
#=> #<GraphMatching::Matching: {[2, 1], [4, 3]}>
```

Explain
-------

Set `ENV['EXPLAIN']` for detailed output, tracing the algorithms.

```bash
EXPLAIN=true bundle exec rspec
```

Glossary
--------

- [Bipartite Graph][3] (bigraph)
- [Graph][7]
- [Matching][6]

References
----------

- West, D. B. (2001). Introduction to graph theory. Upper Saddle River, N.J: Prentice Hall.

[1]: http://www.youtube.com/watch?v=ory4WMX0rDU "The Augmenting Path Algorithm for Bipartite Matching"
[2]: http://www.youtube.com/watch?v=C9c8zEZXboA "The Augmenting Path Algorithm (Example)"
[3]: http://en.wikipedia.org/wiki/Bipartite_graph
[4]: http://rgl.rubyforge.org/rgl/index.html
[5]: http://en.wikipedia.org/wiki/Matching_%28graph_theory%29#In_unweighted_bipartite_graphs
[6]: http://en.wikipedia.org/wiki/Matching_%28graph_theory%29
[7]: http://en.wikipedia.org/wiki/Graph_theory
[8]: http://www.math.uiuc.edu/~stolee/
[9]: http://en.wikipedia.org/wiki/Blossom_algorithm
