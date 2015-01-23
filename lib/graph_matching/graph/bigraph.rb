require 'rgl/traversal'
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
      # proper subsets of vertexes or raises a NotBipartiteError.
      # The bigraph can be disconnected. (http://bit.ly/1rEOgEi)
      def partition
        u = Set.new
        v = Set.new
        return [u,v] if empty?
        each_connected_component do |component|
          i = RGL::BFSIterator.new(self, component.first)
          i.set_examine_edge_event_handler do |from, to|
            examine_edge_for_partition(from, to, u, v)
          end
          i.set_to_end # does the search
        end
        assert_disjoint(u, v) # sanity check
        [u, v]
      end

      private

      def add_to_set(set, vertex, fail_if_in)
        raise NotBipartite if fail_if_in.include?(vertex)
        set.add(vertex)
      end

      def assert_disjoint(u, v)
        raise 'Expected sets to be disjoint' unless u.disjoint?(v)
      end

      def examine_edge_for_partition(from, to, u, v)
        if u.include?(from)
          add_to_set(v, to, u)
        elsif v.include?(from)
          add_to_set(u, to, v)
        else
          u.add(from)
          v.add(to)
        end
      end

    end
  end
end
