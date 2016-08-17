# encoding: utf-8

require 'rgl/adjacency'
require 'rgl/connected_components'
require 'set'
require_relative '../algorithm/mcm_general'
require_relative '../ordered_set'

autoload(:SecureRandom, 'securerandom')

module GraphMatching
  module Graph
    # Base class for all graphs.
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

      def connected?
        count = 0
        each_connected_component { count += 1 }
        count == 1
      end

      def maximum_cardinality_matching
        Algorithm::MCMGeneral.new(self).match
      end

      def max_v
        vertexes.max
      end

      def print
        base_filename = SecureRandom.hex(16)
        Visualize.new(self).png(base_filename)
      end

      def vertexes
        to_a
      end

      def vertexes_must_be_integers
        return if vertices.none? { |v| !v.is_a?(Integer) }
        raise ArgumentError, 'All vertexes must be integers'
      end
    end
  end
end
