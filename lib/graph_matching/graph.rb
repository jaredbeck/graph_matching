require 'rgl/adjacency'
require 'rgl/connected_components'

# TODO: autoload?
require_relative 'shrunken_blossom'

module GraphMatching

  class DisconnectedGraphError < StandardError
  end

  class Graph < RGL::AdjacencyGraph
    include Explainable

    def self.new_from_set_of_edges(edges)
      edges_flattened = edges.map { |e| e.to_a }.flatten
      self[*edges_flattened]
    end

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
    # vertex `ri`, returns an augmented matching.
    def mcm_stage(m, ri)
      log('mcm_stage: matching: ' + m.inspect)

      # Start with a maximal matching M and a queue Q, holding a
      # single unmatched vertex r1 in graph G. Label r1 EVEN (S).
      q = [ri]
      s = LabelSet.new([ri], 'even')
      t = LabelSet.new([], 'odd')

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
          log("------\nv = #{v}, q = #{q}")

          # If v is labeled EVEN (S):
          if s.include?(v)

            #   A) Using breadth-first search, move along all of
            #      the unmatched edges emanating from v. Call the
            #      set of vertices on the opposite end of such edges W.
            w = each_adjacent(v).reject { |x| m.has_edge?([v, x]) }

            #   B) Add the vertices in W to the queue.
            q.concat(w)
            log('w = %s q = %s' % [w, q])

            #      For each w ∈ W
            w.each do |wi|
              log("wi = #{wi}")

            #        If w is not M-covered:
            #          BLOSSOM EXPANSION[w]
            #          Restart entire routine.
              covered = m.has_vertex?(wi)
              if !covered
                fail('TODO: blossom expansion at vertex: %d' % [wi])

            #        If w is M-covered and is labeled EVEN (S):
            #          BLOSSOM SHRINKING[w]
              elsif covered && s.include?(wi)
                log('TODO: blossom shrinking at vertex: %d' % [wi])
                shrink_blossom(wi, ri, v, s, t)

            #        If w is M-covered and is unlabeled:
            #          label w ODD (T)
              else
                t.add(wi, v)
              end
            end

            #      Take v off of the queue.
            #      - We already did!

          #  If v is labeled ODD (T):
          elsif t.include?(v)

            #  A) Move along matched edge to vertex h.
            h = m.match(v)
            log("h = #{h}")

            #    If h is labeled ODD:
            #      BLOSSOM SHRINKING[h]
            #    If h is unlabeled:
            #      label h EVEN.
            if t.include?(h)
              shrink_blossom(h, ri, v, s, t)
            else
              s.add(h, v)
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

    def shrink_blossom(z, ri, v, s, t)
      log('shrink_blossom(z = %s, ri = %s, v = %s)' % [z, ri, v])
      b = blossom_vertexes(ri, s, t, v, z)
      log("blossom_vertexes = #{b.inspect}")
      ea = all_blossom_edges(b)
      shrunken = build_shrunken_blossom(b, ea)
      # shrunken.subgraph.print('blossom2')

      # To shrink the blossom:
      # 1. Remove all edges in the blossom.
      # 2. Reattach edges originally attached to the blossom vertices to vB
      # Recurse into MAIN ROUTINE, starting at lightbulb

      add_vertex(shrunken)
      ea.each do |be|
        remove_edge(*be.to_a)
        vertexes_outside_blossom = Set.new(be.to_a) - b
        if vertexes_outside_blossom.length == 1
          add_edge(vertexes_outside_blossom.first, shrunken)
        end
      end
      b.each do |bv| remove_vertex(bv) end
      print('blossom3')

      fail('TODO')
    end

    def print(base_filename)
      Visualize.new(self).png(base_filename)
    end

    private

    # `all_blossom_edges` returns edges in a blossom, and those
    # immediately adjacent.
    def all_blossom_edges(blossom_vertexes)
      blossom_vertexes.inject(Set.new) { |a, bv|
        a.merge adjacent_vertices(bv).map { |bv2|
          RGL::Edge::UnDirectedEdge.new(bv, bv2)
        }
      }
    end

    # `blossom_vertexes` finds vertexes in the blossom,
    # identified by taking the symmetric difference of (p1, p2)
    # where p1 is the path from `v` to `ri`, and p2 is the path
    # from `z` to `ri`.  These paths are reconstructed by following
    # the label sets `s` and `t`.
    def blossom_vertexes(ri, s, t, v, z)
      p1 = label_path(s, t, from: v, to: ri)
      p2 = label_path(s, t, from: z, to: ri)
      Set.new((p1 ^ p2).to_a.flatten)
    end

    def build_shrunken_blossom(blossom_vertexes, blossom_edges)
      ej = edges_adjacent_to_subgraph(blossom_vertexes)
      g = self.class.new_from_set_of_edges(blossom_edges - ej)
      ShrunkenBlossom.new(g, ej)
    end

    # Given a `Set` of `vertexes`, returns adjacent edges.
    def edges_adjacent_to_subgraph(vertexes)
      edges.select { |e| (vertexes & e.to_a).size == 1 }
    end

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

    def label_path(s, t, from:, to:)
      l = s.v.merge(t.v)
      v = from
      p = Set.new
      until v == to do
        w = l[v]
        p.add([v, w])
        v = w
      end
      p
    end

  end
end
