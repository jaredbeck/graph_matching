# encoding: utf-8

require_relative '../assertion'

module GraphMatching
  module Algorithm
    # All matching algorithms operate on a graph, hence the
    # common constructor.
    class MatchingAlgorithm
      attr_reader :g

      def initialize(graph)
        @g = graph
      end

      def assert(obj)
        Assertion.new(obj)
      end
    end
  end
end
