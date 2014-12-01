require_relative '../matching'
require_relative 'matching_algorithm'

module GraphMatching
  module Algorithm

    # `MWMGeneral` implements Maximum Weighted Matching in
    # general graphs.
    class MWMGeneral < MatchingAlgorithm

      def initialize(graph)
        raise ArgumentError unless graph.is_a?(GraphMatching::Graph::WeightedGraph)
        super
      end

      def match
        fail 'not yet implemented'
      end

    end
  end
end
