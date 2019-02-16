# frozen_string_literal: true

module GraphMatching
  # A `DirectedEdgeSet` is simply a set of directed edges in a
  # graph.  Whether the graph is actually directed or not is
  # irrelevant, we can still discuss directed edges in an undirected
  # graph.
  #
  # The naive implementation would be to use ruby's `Set` and RGL's
  # `DirectedEdge`.  This class is optimized to use a 2D array
  # instead.  The sub-array at index i represents a set (or subset)
  # of vertexes adjacent to i.
  #
  class DirectedEdgeSet
    def initialize(graph_size)
      @edges = Array.new(graph_size + 1) { [] }
    end

    def add(v, w)
      edges[v] << w
    end

    def adjacent_vertices(v)
      edges[v]
    end

    private

    attr_reader :edges
  end
end
