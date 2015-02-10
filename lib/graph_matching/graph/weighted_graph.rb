# encoding: utf-8

require_relative 'weighted'
require_relative '../algorithm/mwm_general'

module GraphMatching
  module Graph
    class WeightedGraph < Graph
      include Weighted

      def maximum_weighted_matching(max_cardinality)
        Algorithm::MWMGeneral.new(self).match(max_cardinality)
      end
    end
  end
end
