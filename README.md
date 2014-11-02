GraphMatching
=============

Efficient algorithms for **maximum cardinality** and
**maximum weighted** [matchings][6] in undirected [graphs][7].
Uses the [Ruby Graph Library (RGL)][4].

Algorithms
----------

This library will implement the four algorithms described by Galil (1986).

### 1. Maximum Cardinality Matching in Bipartite Graphs

Uses the [Augmenting Path][5] algorithm, which performs in O(e * v)
where e is the number of edges, and v, the number of vertexes ([benchmark][14]).

```ruby
require 'graph_matching'
g = GraphMatching::BipartiteGraph[1,3, 1,4, 2,3, 2,4]
g.maximum_cardinality_matching
#=> [(3=2), (4=1)]
```

TO DO: This algorithm is inefficient compared to the [Hopcroft-Karp algorithm][13]
which performs in O(e * sqrt(v)) in the worst case.

### 2. Maximum Cardinality Matching in General Graphs

Uses Gabow (1976) which performs in O(n^3).

```ruby
require 'graph_matching'
g = GraphMatching::Graph[1,2, 1,3, 1,4, 2,3, 2,4, 3,4]
g.maximum_cardinality_matching
#=> [(2=1), (4=3)]
```

Gabow (1976) is not the fastest algorithm, but it is "one exponent
faster" than the original, [Edmonds' blossom algorithm][9], which
performs in O(n^4).

Faster algorithms include Even-Kariv (1975) and Micali-Vazirani (1980).
Galil (1986) describes the latter as "a simpler approach".

### 3. Minimum Weighted Matching in Bipartite Graphs

Not yet implemented.

Currently considering Gabow (1983).

### 4. Minimum Weighted Matching in General Graphs

Not yet implemented.

Currently considering Gabow (1985).

Benchmarks
----------

Benchmarks can be found in `/benchmark` and the github wiki.

Limitations
-----------

All vertexes in a `GraphMatching::Graph` must be integers.  This
simplifies many algorithms.  For your convenience, a module
(`GraphMatching::IntegerVertexes`) is provided to convert the
vertexes of any `RGL::MutableGraph` to integers.

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
- Rantwijk, J. [Maximum Weighted Matching][11]
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
test PR
