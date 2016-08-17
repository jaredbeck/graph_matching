# encoding: utf-8

require 'rgl/bipartite'
require_relative 'graph'
require_relative '../algorithm/mcm_bipartite'

module GraphMatching
  module Graph
    # A bipartite graph (or bigraph) is a graph whose vertices can
    # be divided into two disjoint sets U and V such that every
    # edge connects a vertex in U to one in V.
    class Bigraph < Graph
      def maximum_cardinality_matching
        Algorithm::MCMBipartite.new(self).match
      end

      # `partition` either returns two disjoint (complementary)
      # proper subsets of vertexes or raises a NotBipartite error.
      #
      # An empty graph is partitioned into two empty sets.  This
      # seems natural, but unfortunately is not the behavior of
      # RGL's new `bipartite_sets` function.  So, we have to check
      # for the empty case, but at least we don't have to implement
      # the algorithm ourselves anymore!
      #
      def partition
        if empty?
          [Set.new, Set.new]
        else
          arrays = bipartite_sets
          raise NotBipartite if arrays.nil?
          [Set.new(arrays[0]), Set.new(arrays[1])]
        end
      end
    end
  end
end
