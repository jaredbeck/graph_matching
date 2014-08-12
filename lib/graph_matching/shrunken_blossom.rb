module GraphMatching

  # A ShrunkenBlossom is the subgraph removed during Edmonds'
  # Blossom Algorithm, and a set of its adjacent edges, which
  # will be referenced during expansion.
  class ShrunkenBlossom

    attr_reader :subgraph, :adjacent_edges

    def initialize(subgraph, adjacent_edges)
      @adjacent_edges = adjacent_edges
      @subgraph = subgraph
    end

    def inspect
      to_dot
    end

    def to_dot
      'B' + subgraph.vertices.to_a.join
    end

    def to_s
      to_dot
    end

    def adjacent_edge_including(v)
      adjacent_edges.find { |e| e.to_a.include?(v) }
    end

  end
end
