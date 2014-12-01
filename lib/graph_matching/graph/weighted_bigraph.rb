require_relative 'weighted'
require_relative '../algorithm/mwm_bipartite'

module GraphMatching
  module Graph
    class WeightedBigraph < Bigraph
      include Weighted

      def maximum_weighted_matching
        Algorithm::MWMBipartite.new(self).match
      end
    end
  end
end
