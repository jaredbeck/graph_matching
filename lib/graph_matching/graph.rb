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
      m = maximal_matching
      u = first_unmatched_vertex(m)
      u.nil? ? m : mcm_stage(m, u)
    end

    # `mcm_stage` - Given a matching `m` and an unmatched
    # vertex `u`, returns an augmented matching.
    def mcm_stage(m, u)

      # Start with a maximal matching M and a queue Q, holding a
      # single unmatched vertex r1 (u) in graph G. Label r1 EVEN (S).
      q = [u]
      s = LabelSet.new([u], 'S')
      t = LabelSet.new([], 'T')

      done = false
      until done do

        # If Q isn't empty, take vertex v off the head of the queue.
        # If Q is empty, add a vertex to Q which is unlabeled and
        # not M-covered r2, if it exists. Go to LIGHTBULB. If no
        # such vertex exists, then end.
        if q.empty?
          log('queue is empty')
          r2 = first_unlabeled_unmatched_vertex(s, t, m)
          log("r2 = #{r2}")
          if r2.nil?
            done = true
          else
            q.push(r2)
          end
        else
          v = q.shift
          log("v = #{v}")

          # If v is labeled EVEN (S):
          if s.include?(v)
            log('v is labeled EVEN (S)')

            #   A) Using breadth-first search, move along all of
            #      the unmatched edges emanating from v. Call the
            #      set of vertices on the opposite end of such edges W.
            w = each_adjacent(v).reject { |x| m.has_edge?([v, x]) }
            log('unmatched vertexes adjacent to v: ' + w.inspect)

            #   B) Add the vertices in W to the queue.
            q.concat(w)
            log('new queue: ' + q.inspect)

            #      For each w ∈ W
            w.each do |wi|
              log("wi = #{wi}")

            #        If w is not M-covered:
            #          BLOSSOM EXPANSION[w]
            #          Restart entire routine.
              covered = m.has_vertex?(wi)
              log("covered = #{covered}")
              if !covered
                fail('TODO: blossom expansion at vertex: %d' % [wi])

            #        If w is M-covered and is labeled EVEN (S):
            #          BLOSSOM SHRINKING[w]
              elsif covered && s.include?(wi)
                fail('TODO: blossom shrinking at vertex: %d' % [wi])

            #        If w is M-covered and is unlabeled:
            #          label w ODD
              else
                t.add(wi)
              end
            end

            #      Take v off of the queue.
            #      - We already did!

          #  If v is labeled ODD (T):
          elsif t.include?(v)

            #  A) Move along matched edge to vertex h.
            h = m.match(v)

            #    If h is labeled ODD:
            #      BLOSSOM SHRINKING[h]
            #    If h is unlabeled:
            #      label h EVEN.
            if t.include?(h)
              fail('TODO: blossom shrinking at vertex: %d' % [h])
            else
              s.add(h)
            end

            #  B) Add h to the queue.
            q.push(h)

          else
            raise RuntimeError, "Expected vertex #{v} to be labeled"
          end
        end
      end

      m.validate
    end

    def print(base_filename)
      Visualize.new(self).png(base_filename)
    end

    private

    def first_unlabeled_unmatched_vertex(s, t, m)
      find { |vertex|
        labeled = s.include?(vertex) || t.include?(vertex)
        matched = m.has_vertex?(vertex)
        !labeled && !matched
      }
    end

    def first_unmatched_vertex(m)
      vertices.find { |v| !m.has_vertex?(v) }
    end

  end
end
