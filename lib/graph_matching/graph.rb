require 'rgl/adjacency'
require 'rgl/connected_components'
require_relative 'algorithm/mcm_general'
require_relative 'ordered_set'

module GraphMatching

  class Graph < RGL::AdjacencyGraph

    def self.[](*args)
      super.tap(&:vertexes_must_be_integers)
    end

    def initialize(*args)
      super
      vertexes_must_be_integers
    end

    # `adjacent_vertex_set` is the same as `adjacent_vertices`
    # except it returns a `Set` instead of an `Array`.  This is
    # an optimization, performing in O(n), whereas passing
    # `adjacent_vertices` to `Set.new` would be O(2n).
    def adjacent_vertex_set(v)
      s = Set.new
      each_adjacent(v) do |u| s.add(u) end
      s
    end

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

    def vertexes_must_be_integers
      if vertices.any? { |v| !v.is_a?(Integer) }
        raise ArgumentError, 'All vertexes must be integers'
      end
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
