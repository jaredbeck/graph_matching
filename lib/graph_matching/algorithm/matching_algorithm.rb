module GraphMatching
  module Algorithm

    # All matching algorithms operate on a graph, hence the
    # common constructor.
    class MatchingAlgorithm
      attr_reader :g

      def initialize(graph)
        @g = graph
      end
    end

  end
end
