# encoding: utf-8

require_relative '../graph/weighted_graph'
require_relative '../matching'
require_relative 'matching_algorithm'

module GraphMatching
  module Algorithm

    # `MWMGeneral` implements Maximum Weighted Matching in
    # general graphs.
    class MWMGeneral < MatchingAlgorithm

      # If b is a top-level blossom,
      # label[b] is 0 if b is unlabeled (free);
      #             1 if b is an S-vertex/blossom;
      #             2 if b is a T-vertex/blossom.
      LBL_FREE = 0
      LBL_S = 1
      LBL_T = 2

      attr_reader :mate,
        :endpoint,
        :label,
        :label_end,
        :in_blossom,
        :best_edge,
        :queue,
        :blossom_children

      def initialize(graph)
        assert(graph).is_a(Graph::WeightedGraph)
        super

        # In Joris van Rantwijk's implementation, there seems to be
        # a concept of "edge numbers".  His `endpoint` array has two
        # elements for each edge.  His `mate` array "points to" his
        # `endpoint` array.  (See below)  I'm sure there's a reason,
        # but I don't understand yet.
        #
        # > If p is an edge endpoint,
        # > endpoint[p] is the vertex to which endpoint p is attached.
        # > Not modified by the algorithm.
        # > (van Rantwijk, mwmatching.py)
        #
        @endpoint = g.edges.map { |e| [e.source, e.target] }.flatten

        # > If v is a vertex,
        # > mate[v] is the remote endpoint of its matched edge, or -1 if it is single
        # > (i.e. endpoint[mate[v]] is v's partner vertex).
        # > Initially all vertices are single; updated during augmentation.
        # > (van Rantwijk, mwmatching.py)
        #
        @mate = Array.new(g.num_vertices, nil)
        @label = Array.new(2 * g.num_vertices, LBL_FREE)
        @label_end = Array.new(2 * g.num_vertices, nil)
        @in_blossom = Array.new(g.num_vertices, nil)
        @best_edge = Array.new(2 * g.num_vertices, nil)
        @queue = []

        # If b is a non-trivial (sub-)blossom,
        # blossomchilds[b] is an ordered list of its sub-blossoms, starting with
        # the base and going round the blossom.
        @blossom_children = Array.new(2 * g.num_vertices, nil)
      end

      def log(indent, msg)
        space = ' '
        indent_str = space * 2 * indent.to_i
        puts '%s%s' % [indent_str, msg]
      end

      # > Assign label t to the top-level blossom containing vertex w
      # > and record the fact that w was reached through the edge with
      # > remote endpoint p.
      # > (van Rantwijk, mwmatching.py)
      #
      def assign_label(w, t, p = nil)
        b = in_blossom[w]
        unless free?(w) && free?(b)
          raise "Expected vertex #{w} and blossom #{b} to be free"
        end
        label[w] = label[b] = t
        label_end[w] = label_end[b] = p
        best_edge[w] = best_edge[b] = nil
        if t == LBL_S
          # b became an S-vertex/blossom; add it(s vertices) to the queue.
          queue.concat(blossom_leaves(b))
        elsif t == LBL_T
          # b became a T-vertex/blossom; assign label S to its mate.
          # (If b is a non-trivial blossom, its base is the only vertex
          # with an external mate.)
          base = blossom_base[b]
          if mate[base].nil?
            raise "Expected blossom #{b}'s base (#{base}) to be matched"
          end

          # Assign label S to the mate of blossom b's base.
          # Remember, `mate` elements are pointers to "endpoints".
          # The bitwise XOR is very clever. `mate[x]` and `mate[x] ^ 1`
          # are connected "endpoints".
          base_edge_endpoints = [mate[base], mate[base] ^ 1]
          assign_label(endpoint[base_edge_endpoints[0]], LBL_S, base_edge_endpoints[1])
        else
          raise ArgumentError, "Unexpected label: #{t}"
        end
      end

      # TODO: Optimize by returning lazy iterator
      def blossom_leaves(b, ary = [])
        if leaf?(b)
          ary.push(b)
        else
          blossom_children[b].each do |c|
             if leaf?(c)
               ary.push(c)
             else
               ary.concat(blossom_leaves(c))
             end
          end
        end
        ary
      end

      # TODO: Optimize by de-normalizing.
      def leaf?(x)
        x < g.num_vertices
      end

      # > As in Problem 3, the algorithm consists of O(n) *stages*.
      # > In each stage we look for an augmenting path using the
      # > labeling R12 and the two cases C1, C2 as in the simple
      # > algorithm for Problem 2, except that we only use edges
      # > with π<sub>ij</sub> = 0. (Galil, 1986, p. 32)
      def match
        return Matching.new if g.size < 2

        u = init_vertex_duals
        z = [] # blossom duals
        b = [] # blossoms

        # Iterative *stages*.  In each we look for an augmenting path.
        while true do
          log(0, "stage. m = #{m}")
          p = nil # augmenting path

          # Queue of newly discovered S-vertices.
          q = []

          # > We start by labeling all single persons S (Galil, 1986, p. 26)
          g.each_vertex do |v|
            if matched?(v) && label[in_blossom[v]] == LBL_FREE
              assign_label(v, LBL_S)
            end
          end

          # If all vertexes are matched, we're done!
          break if s.empty?

          # > The search is conducted by scanning the S-vertices in turn.
          # > Scanning a vertex means considering in turn all its edges
          # > except the matched edge. (There will be at most one).
          # > (Galil, 1986, p. 26)
          scan = s.keys.dup
          scan.each do |i|
            log(1, "scan #{i}")
            adj = unmatched_adjacent(i, m)

            # > we only use edges with π<sub>ij</sub> = 0. (Galil, 1986, p. 32)
            adj.each do |j|
              log(2, "adj #{j}. π = #{π(i, j, u, z)}")
              next unless π(i, j, u, z) == 0

              # > If we scan the S-vertex *i* and consider the edge (i,j),
              # > there are two cases:
              # >
              # > * (C1) j is free; or
              # > * (C2) j is an S-vertex
              # >
              # > C2 cannot occur in the bipartite case.  The case in
              # > which j is a T-vertex is discarded.
              # > (Galil, 1986, p. 26-27)
              if free?(j, [s, t])

                # > In case C1 we apply R12. (Galil, 1986, p. 27)
                #
                # > * (R1) If (i, j) is not matched and i is an S-person
                # >   and j a free (unlabeled) person then label j by T; and
                # > * (R2) If (i, j) is matched and j is a T-person
                # >   and i a free person, then label i by S.
                # >
                # > Modified from (Galil, 1986, p. 25) as follows:
                #
                # > Any time R1 is used and j is labeled by T, R2 is
                # > immediately used to label the spouse of j with S.
                # > (Since j was not labeled before, it must be married
                # > and its spouse must be unlabeled.)  We call this
                # > rule R12. (Galil, 1986, p. 26)

                # R12
                if !matched_edge?(i, j, m) && s.key?(i) && free?(j, [s, t])
                  t[j] = i
                  s[m[j]] = j # "label the spouse of j with S" (see above)
                end

              elsif s.key?(j)

                # (C2) j is an S-vertex
                #
                # > Backtrack from i and j, using the labels, to the
                # > single persons s<sub>i</sub> and s<sub>j</sub>
                # > from which i and j got their S labels.  If
                # > s<sub>i</sub> ≠ s<sub>j</sub>, we find an augmenting
                # > path from s<sub>i</sub> to s<sub>j</sub> and augment
                # > the matching. (Galil, 1986, p. 27)
                back_i = s[i]
                back_j = s[j]
                if back_i.nil? && back_j.nil?
                  log(3, "trivial AP")
                  p = [i, j]
                elsif back_i != back_j
                  log(3, "backtrack AP")
                  p = backtrack(j, s)
                else
                  log(3, "blossom shrinking")
                  fail 'Not yet implemented: blossom shrinking'
                end

              end

              break unless p.nil?
            end

            break unless p.nil?
          end # scan

          if p.nil?
            scale_duals(s, t, tb, u, z)
          else
            log(1, "augment. #{p}")
            augment(m, p)
          end

        end # stage

        Matching.gabow(m)
      end

      # Pseudo-private
      # --------------
      #
      # Eventually, these methods will probably be private.  For now,
      # they are public so they can be easily tested.
      #

      def augment(m, path)
        ap = Path.new(path)
        augmenting_path_edges = ap.edges
        raise "invalid augmenting path: must have odd length" unless augmenting_path_edges.length.odd?
        ap.vertexes.each do |v|
          w = m[v]
          unless w.nil?
            m[v] = nil
            m[w] = nil
          end
        end
        augmenting_path_edges.each_with_index do |edge, ix|
          if ix.even?
            i, j = edge
            m[i] = j
            m[j] = i
          end
        end
        m
      end

      def backtrack(v, labels)
        p = [v]
        while n = labels[p.last]
          p.push(n)
        end
        p
      end

      def free?(x)
        @label[x] == LBL_FREE
      end

      def init_s_labels(m)
        s = {}
        g.each_vertex do |i|
          if m[i].nil?
            s[i] = nil
          end
        end
        s
      end

      def init_vertex_duals
        u = []
        g.each_vertex do |i| u[i] = g.max_w / 2 end
        u
      end

      # Returns true if vertex `i` is matched in `m`.
      def matched?(i, m)
        !m[i].nil?
      end

      # Returns true if edge i,j is matched in `m`.
      def matched_edge?(i, j, m)
        !m[i].nil? && !m[j].nil? && m[i] == j && m[j] == i
      end

      def present_indexes_in(array)
        array.each_with_index.reduce([]) { |accum, (elm, ix)|
          elm.nil? ? accum : accum.push(ix)
        }
      end

      # > If the search is not successful, we make the following
      # > changes in the dual variables.
      def scale_duals(s, t, tb, u, z)
        log(1, 'scale.')
        s_vtx = s.keys
        t_vtx = t.keys
        free_vtx = Set[g.vertexes] - s_vtx - t_vtx
        d1 = s_vtx.map { |i| u[i] }.min
        log(2, "d1 = #{d1}")
        d2 = s_free_slacks(s_vtx, s, t, u, z).min
        log(2, "d2 = #{d2}")
        d3 = cross_blossom_s_edge_half_slacks(s_vtx, u, z).min
        log(2, "d3 = #{d3}")
        d4 = t_blossom_duals(tb, z).min
        log(2, "d4 = #{d4}")
        d = [d1, d2, d3, d4].compact.min # TODO: is compact a problem?
        log(2, "d = #{d}")
        fail 'Not yet implemented: scale the duals'
      end

      def t_blossom_duals(tb, z)
        tb.map { |k| z[k] }
      end

      # Returns edges i,j where i ∈ S and j ∈ S.
      def s_edges(s_vtx)
        edges = Set.new
        s_vtx.each do |i|
          g.each_adjacent(i) do |j|
            if s_vtx.include?(j)
              edges.add(RGL::Edge::UnDirectedEdge.new(i, j))
            end
          end
        end
        edges
      end

      # Returns true unless i and j are in the same blossom.
      def cross_blossom?(i, j)
        true # TODO: how are blossoms stored?
      end

      def cross_blossom_s_edges(s_vtx)
        s_edges(s_vtx).select { |(i, j)| cross_blossom?(i, j) }
      end

      # Returns half-slacks (simply slack / 2) for S-edges i,j
      # where i and j are not in the same blossom.
      def cross_blossom_s_edge_half_slacks(s_vtx, u, z)
        cross_blossom_s_edges(s_vtx).map { |(i, j)| π(i, j, u, z).to_f / 2 }
      end

      # Returns slacks of edges between S-vertexes and adjacent
      # free vertexes.
      def s_free_slacks(s_vtx, s, t, u, z)
        slacks = []
        s_vtx.each do |i|
          g.each_adjacent(i) do |j|
            if free?(j, [s, t])
              slacks.push π(i, j, u, z)
            end
          end
        end
        slacks
      end

      def unmatched_adjacent(v, m)
        g.adjacent_vertices(v).select { |i| m[v] != i }
      end

      # > We now define slacks π<sub>ij</sub> slightly differently
      # > [compared to problem 3]. (Galil, 1986, p.31)
      def π(i, j, u, z)
        u[i] + u[j] - g.w([i, j]) + Σz(i, j, z)
      end

      # Σ<sub>ij ∈ Bk</sub> zk
      #
      # The sum of the duals (z) of every blossom with edge ij.
      def Σz(i, j, z)
        z.select { |k| k.graph.has_edge?(i, j) }.
          reduce(0) { |sum, k| sum + k.dual }
      end
    end
  end
end
