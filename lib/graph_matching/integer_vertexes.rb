module GraphMatching
  module IntegerVertexes

    # `to_integers` converts the vertices of `graph` to integers.
    # For example, given a graph (a=b), returns a new graph (1=2).
    # It also returns a legend, which maps the integers to the
    # original vertexes.
    #
    # This function is useful because many graph matching algorithms
    # require integral (integer) vertexes.
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
      return new_graph, legend
    end

  end
end
