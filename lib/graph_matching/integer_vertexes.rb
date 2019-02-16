# frozen_string_literal: true

module GraphMatching
  # Converts the vertices of a graph to integers.  Many graph
  # matching algorithms require integer vertexes.
  module IntegerVertexes
    # Converts the vertices of `graph` to positive nonzero integers.
    # For example, given a graph (a=b), returns a new graph (1=2).
    # It also returns a legend, which maps the integers to the
    # original vertexes.
    #
    def self.to_integers(graph)
      raise ArgumentError unless graph.is_a?(RGL::MutableGraph)
      legend = {}
      reverse_legend = {}
      new_graph = graph.class.new
      graph.vertices.each_with_index do |vertex, ix|
        legend[ix + 1] = vertex
        reverse_legend[vertex] = ix + 1
      end
      graph.edges.each do |edge|
        source = reverse_legend[edge.source]
        target = reverse_legend[edge.target]
        new_graph.add_edge(source, target)
      end
      [new_graph, legend]
    end
  end
end
