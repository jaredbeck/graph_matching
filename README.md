# GraphMatching

Finds maximum matchings in undirected graphs.

Implements modern algorithms for finding maximum cardinality
and maximum weighted matchings in undirected graphs and bigraphs.

## Usage

```ruby
require 'graph_matching'
g = GraphMatching::BipartiteGraph.new
g.add_edge('alice', 'bob')
g.add_edge('christine', 'don')
g.maximum_cardinality_matching
#=> #<Set: {['alice', 'don'], ['christine', 'bob']}>
```
