require 'rgl/adjacency'
require 'rgl/connected_components'
require_relative 'algorithm/mcm_general'
require_relative 'ordered_set'

module GraphMatching

  class Graph < RGL::AdjacencyGraph

    def backtrack_from(end_vertex, predecessors)
      augmenting_path = [end_vertex]
      while predecessors.has_key?(augmenting_path.last)
        augmenting_path.push(predecessors[augmenting_path.last])
      end
      augmenting_path
    end

    def connected?
      count = 0
      each_connected_component { |c| count += 1 }
      count == 1
    end

    def maximum_cardinality_matching
      Algorithm::MCMGeneral.new(self).match
    end

    def print(base_filename)
      Visualize.new(self).png(base_filename)
    end

    def vertexes
      to_a
    end

    private

    # `unmatched_adjacent_to` is poorly named.  It returns vertexes
    # across adjacent unmatched edges.  However, vertexes in the
    # returned array may be matched by non-adjacent edges.
    def unmatched_adjacent_to(vertex, matching)
      adjacent_vertices(vertex).reject { |a| matching.has_edge?([vertex, a]) }
    end

  end
end
