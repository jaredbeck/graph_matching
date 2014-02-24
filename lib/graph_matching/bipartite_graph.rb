require_relative 'graph'
require 'rgl/traversal'

module GraphMatching

  class NotBipartiteError < StandardError
  end

  # A bipartite graph (or bigraph) is a graph whose vertices can
  # be divided into two disjoint sets U and V such that every
  # edge connects a vertex in U to one in V.
  class BipartiteGraph < Graph

    # `maximum_cardinality_matching` returns a `Set` of arrays,
    # each representing an edge in the matching.
    #
    # The Augmenting Path algorithm is used.
    #
    # For each stage (until no augmenting path is found)
    # 0. Clear all labels and marks
    # 1. Label unmatched vertexes in U with label R
    # 2. Mark the leftmost unmarked R-vertex
    # 3. Follow the unmatched edges (if any) to vertexes in V
    # 4. Does the vertex in V have label T?
    #   A. If yes, do what?
    #   B. If no, label with T and mark.  Now, is it matched?
    #     i. If so, follow that edge to a vertex in U
    #       a. Label the U-vertex with R
    #       b. Stop.  Return to step 2
    #     ii. If not,
    #       a. Backtrack to construct an augmenting path
    #       a. Augment the matching and return to step 1
    # 5. If every U-vertex is labeled and marked, and no augmenting
    #    path was found, the algorithm halts.
    #
    def maximum_cardinality_matching
      Set.new
    end

    # `partition` either returns two disjoint proper subsets
    # of vertexes or raises a NotBipartiteError
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

  private

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

    def add_to_set(set, vertex:, fail_if_in:)
      raise NotBipartiteError if fail_if_in.include?(vertex)
      set.add(vertex)
    end

    def assert_disjoint(u, v)
      raise "Expected sets to be disjoint" unless u.disjoint?(v)
    end

  end
end
