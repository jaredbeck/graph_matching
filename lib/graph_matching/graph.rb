require 'rgl/adjacency'
require 'rgl/connected_components'

module GraphMatching

  class DisconnectedGraphError < StandardError
  end

  class Graph < RGL::AdjacencyGraph
    include Explainable

    def backtrack_from(end_vertex, predecessors)
      # log("found augmenting path. backtracking ..")
      augmenting_path = [end_vertex]
      # log("predecessors: #{predecessors.inspect}")
      while predecessors.has_key?(augmenting_path.last)
        augmenting_path.push(predecessors[augmenting_path.last])
      end
      # log("augmenting path: #{augmenting_path.inspect}")
      augmenting_path
    end

    def connected?
      count = 0
      each_connected_component { |c| count += 1 }
      count == 1
    end

    # `maximal_matching` - Not to be confused with a *maximum* matching.
    # > A maximal matching is defined as a matching in which
    # > no edge in G can be added to the matching.
    # > (Kusner, Edmonds's Blossom Algorithm, p. 1)
    def maximal_matching
      m = Matching.new
      edges.each do |e|
        if m.unmatched_vertexes_in(Set.new(e.to_a)).length == 2
          m.add(e.to_a)
        end
      end
      m.validate
    end

    def maximum_cardinality_matching
      return Matching.new if empty?
      raise DisconnectedGraphError unless connected?
      mcm_stage(Matching.new, vertices.first)
    end

    # `mcm_stage` - Given a matching `m` and an unmatched
    # vertex `u`, returns an augmented matching.
    def mcm_stage(m, u)
      done = false
      until done do

        # Start with a maximal matching M and a queue Q, holding a
        # single unmatched vertex r1 (u) in graph G. Label r1 EVEN (S).
        q = [u]
        s = LabelSet.new([u], 'S')
        t = LabelSet.new([], 'T')

        # If Q isn't empty, take vertex v off the head of the queue.
        # If Q is empty, add a vertex to Q which is unlabeled and
        # not M-covered r2, if it exists. Go to LIGHTBULB. If no
        # such vertex exists, then end.
        if q.empty?
          r2 = find { |vertex| !s.include?(vertex) && !m.has_vertex?(vertex) }
          if r2.nil?
            done = true
          else
            q.push(r2)
          end
        else
          v = q.shift

          # If v is labeled EVEN (S):
          if s.include?(v)

            #   A) Using breadth-first search, move along all of
            #      the unmatched edges emanating from v. Call the
            #      set of vertices on the opposite end of such edges W.
            w = Set.new
            i = RGL::BFSIterator.new(self)
            i.set_examine_edge_event_handler do |from, to|

            end
            i.set_to_end # does the search

            #   B) Add the vertices in W to the queue.
            #      For each w ∈ W
            #        If w is not M-covered:
            #          BLOSSOM EXPANSION[w]
            #          Restart entire routine.
            #        If w is M-covered and is labeled EVEN:
            #          BLOSSOM SHRINKING[w]
            #        If w is M-covered and is unlabeled:
            #          label w ODD
            #      Take v off of the queue.

          #  If v is labeled ODD:
          elsif t.include?(v)

            #  A) Move along matched edge to vertex h.
            #    If h is labeled ODD:
            #      BLOSSOM SHRINKING[h]
            #    If h is unlabeled:
            #      label h EVEN.
            #  B) Add h to the queue.


          else
            raise RuntimeError, "Expected vertex #{v} to be labeled"
          end
        end
      end
    end

    def print(base_filename)
      Visualize.new(self).png(base_filename)
    end

  end
end
