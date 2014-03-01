require 'rgl/adjacency'
require 'rgl/connected_components'

module GraphMatching

  class DisconnectedGraphError < StandardError
  end

  class Graph < RGL::AdjacencyGraph

    def connected?
      count = 0
      each_connected_component { |c| count += 1 }
      count == 1
    end

    def maximum_cardinality_matching
      return Matching.new if empty?
      raise DisconnectedGraphError unless connected?
      mcm_stage(Matching.new, vertices.first)
    end

    # `mcm_stage` - Given a matching `m` and an unmatched
    # vertex `u`, returns an augmented matching.
    def mcm_stage(m, u)
      s = LabelSet.new([u], 'S')
      t = LabelSet.new([], 'T')
      mark = LabelSet.new([], 'mark')

      # If S has no unmarked vertex, stop; there is no M-augmenting
      # path from u.  Otherwise, select an unmarked v ∈ S.  To
      # explore from v, successively consider each y ∈ N(v) such
      # that y ∉ T.
      #
      # If y is unsaturated by M, then trace back from y (expanding
      # blossoms as needed) to report an M-augmenting u, y-path.
      #
      # If y ∈ S, then a blossom has been found.  Suspend the
      # exploration of v and contract the blossom, replacing its
      # vertices in S and T by a single new vertex in S.  Continue
      # the search from this vertex in the smaller graph.
      #
      # Otherwise, y is matched to some w by M.  Include y in T
      # (reached from v), and include w in S (reached from y).
      #
      # After exploring all such neighbors of v, mark v and iterate.
    end

  end
end
