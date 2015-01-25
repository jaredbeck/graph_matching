# encoding: utf-8

require_relative '../graph/weighted_graph'
require_relative '../matching'
require_relative 'matching_algorithm'

module GraphMatching
  module Algorithm

    # `MWMGeneral` implements Maximum Weighted Matching in
    # general graphs.
    class MWMGeneral < MatchingAlgorithm

      def initialize(graph)
        assert(graph).is_a(Graph::WeightedGraph)
        super
      end

      def match
        return Matching.new if g.size <= 1
        fail 'not yet implemented'
      end

      private

    end
  end
end
