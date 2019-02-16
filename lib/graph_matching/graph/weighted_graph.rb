# frozen_string_literal: true

require_relative 'weighted'
require_relative '../algorithm/mwm_general'

module GraphMatching
  module Graph
    # A graph whose edges have weights.  See `Weighted`.
    class WeightedGraph < Graph
      include Weighted

      def maximum_weighted_matching(max_cardinality)
        Algorithm::MWMGeneral.new(self).match(max_cardinality)
      end
    end
  end
end
