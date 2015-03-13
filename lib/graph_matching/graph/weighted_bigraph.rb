# encoding: utf-8

require_relative 'weighted'
require_relative '../algorithm/mwm_bipartite'

module GraphMatching
  module Graph
    # A bigraph whose edges have weights.  See `Weighted`.
    class WeightedBigraph < Bigraph
      include Weighted

      def maximum_weighted_matching
        Algorithm::MWMBipartite.new(self).match
      end
    end
  end
end
