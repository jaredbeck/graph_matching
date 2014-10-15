require 'rgl/traversal'
require_relative 'algorithm/mcm_bipartite'
require_relative 'graph'

module GraphMatching

  class NotBipartiteError < StandardError
  end

  # A bipartite graph (or bigraph) is a graph whose vertices can
  # be divided into two disjoint sets U and V such that every
  # edge connects a vertex in U to one in V.
  class BipartiteGraph < Graph

    def maximum_cardinality_matching
      Algorithm::MCMBipartite.new(self).match
    end

    # `partition` either returns two disjoint (complementary)
    # proper subsets of vertexes or raises a NotBipartiteError
    def partition
      u = Set.new
      v = Set.new
      return [u,v] if empty?
      raise NotBipartiteError unless connected?
      i = RGL::BFSIterator.new(self)
      i.set_examine_edge_event_handler do |from, to|
        examine_edge_for_partition(from, to, u, v)
      end
      i.set_to_end # does the search
      assert_disjoint(u, v) # sanity check
      [u, v]
    end

    def matched_adjacent_to(vertex, adjacent_vertexes, matching)
      adjacent_vertexes.select { |x| matching.has_edge?([x, vertex]) }
    end

    def unmatched_unlabled_adjacent_to(vertex, matching, labels)
      unmatched_adjacent_to(vertex, matching).reject { |v| labels.include?(v) }
    end

    def vertices_adjacent_to(vertex, except: [])
      adjacent_vertices(vertex) - except
    end

    private

    def add_to_set(set, vertex:, fail_if_in:)
      raise NotBipartiteError if fail_if_in.include?(vertex)
      set.add(vertex)
    end

    def assert_disjoint(u, v)
      raise 'Expected sets to be disjoint' unless u.disjoint?(v)
    end

    def examine_edge_for_partition(from, to, u, v)
      if u.include?(from)
        add_to_set(v, vertex: to, fail_if_in: u)
      elsif v.include?(from)
        add_to_set(u, vertex: to, fail_if_in: v)
      else
        u.add(from)
        v.add(to)
      end
    end

  end
end
