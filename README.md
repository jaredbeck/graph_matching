GraphMatching
=============

Efficient algorithms for **maximum cardinality** and
**maximum weighted** [matchings][6] in undirected [graphs][7].
Uses the [Ruby Graph Library (RGL)][4].

[![Build Status][20]][23]
[![Code Climate][22]][21]

Algorithms
----------

This library will implement the four algorithms described by Galil (1986).
When all four have been implemented, a gem version 1.0.0 will be released.

### 1. Maximum Cardinality Matching in Bipartite Graphs

Uses the [Augmenting Path][5] algorithm, which performs in O(e * v)
where e is the number of edges, and v, the number of vertexes ([benchmark][14]).

```ruby
require 'graph_matching'
g = GraphMatching::Graph::Bigraph[1,3, 1,4, 2,3]
m = g.maximum_cardinality_matching
m.edges
#=> [[4, 1], [3, 2]]
```

![MCM in Complete Bigraph is O(e * v)][17]

See [Benchmarking MCM in Complete Bigraphs][14]

TO DO: This algorithm is inefficient compared to the [Hopcroft-Karp algorithm][13]
which performs in O(e * sqrt(v)) in the worst case.

### 2. Maximum Cardinality Matching in General Graphs

Uses Gabow (1976) which performs in O(n^3).

```ruby
require 'graph_matching'
g = GraphMatching::Graph::Graph[1,2, 1,3, 1,4, 2,3, 2,4, 3,4]
m = g.maximum_cardinality_matching
m.edges
#=> [[2, 1], [4, 3]]
```


![MCM in Complete Graph is O(v ^ 3)][18]

See [Benchmarking MCM in Complete Graphs][15]

Gabow (1976) is not the fastest algorithm, but it is "one exponent
faster" than the original, [Edmonds' blossom algorithm][9], which
performs in O(n^4).

Faster algorithms include Even-Kariv (1975) and Micali-Vazirani (1980).
Galil (1986) describes the latter as "a simpler approach".

### 3. Maximum Weighted Matching in Bipartite Graphs

Uses the [Augmenting Path][5] algorithm from Maximum Cardinality
Matching, with the "scaling" approach described by Gabow (1983)
and Galil (1986), which performs in O(n ^ (3/4) m log N).

```ruby
require 'graph_matching'
g = GraphMatching::Graph::WeightedBigraph[1,2, 1,3]
g.set_w([1,2], 100)
g.set_w([1,3], 101)
m = g.maximum_weighted_matching
m.edges
#=> [[3, 1]]
m.weight(g)
#=> 101
```

![MWM in Complete Bigraph is O(n ^ (3/4) m log N)][19]

See [Benchmarking MWM in Complete Bigraphs][16]

### 4. Maximum Weighted Matching in General Graphs

Implementation underway, borrowing heavily from
[Van Rantwijk (2013)][11], while referring to
Gabow (1985) and, of course, Galil (1986).

Benchmarks
----------

Benchmarks can be found in `/benchmark` and the github wiki.

Limitations
-----------

All vertexes in a `Graph` must be consecutive positive nonzero
integers.  This simplifies many algorithms.  For your convenience,
a module (`GraphMatching::IntegerVertexes`) is provided to convert
the vertexes of any `RGL::MutableGraph` to integers.

```ruby
require 'graph_matching'
require 'graph_matching/integer_vertexes'
g1 = RGL::AdjacencyGraph['a', 'b']
g2, legend = GraphMatching::IntegerVertexes.to_integers(g1)
g2.vertices
#=> [1, 2]
legend
#=> {1=>"a", 2=>"b"}
```

Troubleshooting
---------------

* If you have [graphviz][24] installed, calling `#print` on
  any `GraphMatching::Graph` will write a `png` to `/tmp` and
  `open` it.

Glossary
--------

- [Bipartite Graph][3] (bigraph)
- [Graph][7]
- [Matching][6]

References
----------

- Edmonds, J. (1965). Paths, trees, and flowers. *Canadian Journal
of Mathematics*.
- Even, S. and Kariv, O. (1975). An O(n^2.5) Algorithm for Maximum
Matching in General Graphs. *Proceedings of the 16th Annual IEEE
Symposium on Foundations of Computer Science*. IEEE, New York, pp. 100-112
- Kusner, M. [Edmonds's Blossom Algorithm (pdf)][12]
- Gabow, H. J. (1973). Implementation of algorithms for maximum
matching on nonbipartite graphs, Stanford Ph.D thesis.
- Gabow, H. N. (1976). An Efficient Implementation of Edmonds'
Algorithm for Maximum Matching on Graphs. *Journal of the Association
for Computing Machinery*, Vol. 23, No. 2, pp. 221-234
- Gabow, H. N. (1983). Scaling algorithms for network problems.
*Proceedings of the 24th Annual IEEE Symposium on Foundations of
Computer Science*. IEEE, New York, pp. 248-257
- Gabow, H. N. (1985). A scaling algorithm for weighted matching on
general graphs. *Proceedings of the 26th Annual IEEE Symposium on
Foundations of Computer Science*. IEEE, New York, pp. 90-100
- Galil, Z. (1986). Efficient algorithms for finding maximum
matching in graphs. *ACM Computing Surveys*. Vol. 18, No. 1, pp. 23-38
- Micali, S., and Vazirani, V. (1980). An O(e * sqrt(v)) Algorithm for
finding maximal matching in general graphs. *Proceedings of the 21st
Annual IEEE Symposium on Foundations of Computer Science*.
IEEE, New York, pp. 17-27
- Van Rantwijk, J. (2013) [Maximum Weighted Matching][11]
- [Stolee, D.][8]
    - [The Augmenting Path Algorithm for Bipartite Matching][1]
    - [The Augmenting Path Algorithm (Example)][2]
- West, D. B. (2001). *Introduction to graph theory*. Prentice Hall. p. 142
- Zwick, U. (2013). [Lecture notes on: Maximum matching in bipartite
and non-bipartite graphs (pdf)][10]

[1]: http://www.youtube.com/watch?v=ory4WMX0rDU "The Augmenting Path Algorithm for Bipartite Matching"
[2]: http://www.youtube.com/watch?v=C9c8zEZXboA "The Augmenting Path Algorithm (Example)"
[3]: http://en.wikipedia.org/wiki/Bipartite_graph
[4]: http://rgl.rubyforge.org/rgl/index.html
[5]: http://en.wikipedia.org/wiki/Matching_%28graph_theory%29#In_unweighted_bipartite_graphs
[6]: http://en.wikipedia.org/wiki/Matching_%28graph_theory%29
[7]: http://en.wikipedia.org/wiki/Graph_theory
[8]: http://www.math.uiuc.edu/~stolee/
[9]: http://en.wikipedia.org/wiki/Blossom_algorithm
[10]: http://www.cs.tau.ac.il/~zwick/grad-algo-13/match.pdf
[11]: http://jorisvr.nl/maximummatching.html
[12]: http://matthewkusner.com/MatthewKusner_BlossomAlgorithmReport.pdf
[13]: http://en.wikipedia.org/wiki/Hopcroft%E2%80%93Karp_algorithm
[14]: https://github.com/jaredbeck/graph_matching/wiki/Benchmarking-MCM-in-Complete-Bigraphs
[15]: https://github.com/jaredbeck/graph_matching/wiki/Benchmarking-MCM-in-Complete-Graphs
[16]: https://github.com/jaredbeck/graph_matching/wiki/Benchmarking-MWM-in-Complete-Bigraphs
[17]: https://github.com/jaredbeck/graph_matching/blob/master/benchmark/mcm_bipartite/complete_bigraphs/plot.png
[18]: https://github.com/jaredbeck/graph_matching/blob/master/benchmark/mcm_general/complete_graphs/plot.png
[19]: https://github.com/jaredbeck/graph_matching/blob/master/benchmark/mwm_bipartite/complete_bigraphs/plot.png
[20]: https://travis-ci.org/jaredbeck/graph_matching.svg?branch=master
[21]: https://codeclimate.com/github/jaredbeck/graph_matching
[22]: https://codeclimate.com/github/jaredbeck/graph_matching/badges/gpa.svg
[23]: https://travis-ci.org/jaredbeck/graph_matching/builds
[24]: http://www.graphviz.org/
