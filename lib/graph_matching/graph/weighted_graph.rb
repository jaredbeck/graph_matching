# encoding: utf-8

require_relative 'weighted'
require_relative '../algorithm/mwm_general'

module GraphMatching
  module Graph
    class WeightedGraph < Graph
      include Weighted

      def maximum_weighted_matching
        Algorithm::MWMGeneral.new(self).match
      end
    end
  end
end
