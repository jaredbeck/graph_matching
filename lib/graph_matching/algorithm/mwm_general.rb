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
      LBL_NAMES = ['Free', 'S', 'T']

      attr_reader :tight_edge,
        :mate,
        :endpoint,
        :label,
        :label_end,
        :in_blossom,
        :best_edge,
        :queue,
        :blossom_children,
        :neighb_end

      def initialize(graph)
        assert(graph).is_a(Graph::WeightedGraph)
        assert(graph.vertexes).are_natural_numbers
        super

        # As we build our "state" throughout this constructor, we'll
        # iterate over the edges a few times.  It's important that
        # the order of iteration be consistent.
        edges = g.edges.to_a

        # In Joris van Rantwijk's implementation, there seems to be
        # a concept of "edge numbers".  His `endpoint` array has two
        # elements for each edge.  His `mate` array "points to" his
        # `endpoint` array.  (See below)  I'm sure there's a reason,
        # but I don't understand yet.
        #
        # > If p is an edge endpoint,
        # > endpoint[p] is the vertex to which endpoint p is attached.
        # > Not modified by the algorithm.
        # > (van Rantwijk, mwmatching.py, line 93)
        #
        @endpoint = edges.map { |e| [e.source, e.target] }.flatten

        # > If v is a vertex,
        # > neighbend[v] is the list of remote endpoints of the edges attached to v.
        # > Not modified by the algorithm.
        # > (van Rantwijk, mwmatching.py, line 98)
        @neighb_end = Array.new(g.num_vertices) { [] }
        edges.each_with_index do |e, k|
          @neighb_end[e.source].push(2 * k + 1)
          @neighb_end[e.target].push(2 * k)
        end

        # > If v is a vertex,
        # > mate[v] is the remote endpoint of its matched edge, or -1 if it is single
        # > (i.e. endpoint[mate[v]] is v's partner vertex).
        # > Initially all vertices are single; updated during augmentation.
        # > (van Rantwijk, mwmatching.py)
        #
        @mate = Array.new(g.num_vertices, nil)

        # > If b is a top-level blossom,
        # > label[b] is 0 if b is unlabeled (free);
        # >             1 if b is an S-vertex/blossom;
        # >             2 if b is a T-vertex/blossom.
        # > The label of a vertex is found by looking at the label of its
        # > top-level containing blossom.
        # > If v is a vertex inside a T-blossom,
        # > label[v] is 2 iff v is reachable from an S-vertex outside the blossom.
        # > Labels are assigned during a stage and reset after each augmentation.
        # > (van Rantwijk, mwmatching.py)
        #
        @label = rantwijk_array(LBL_FREE)

        # > If b is a labeled top-level blossom,
        # > labelend[b] is the remote endpoint of the edge through which b obtained
        # > its label, or -1 if b's base vertex is single.
        # > If v is a vertex inside a T-blossom and label[v] == 2,
        # > labelend[v] is the remote endpoint of the edge through which v is
        # > reachable from outside the blossom.
        # > (van Rantwijk, mwmatching.py)
        #
        @label_end = rantwijk_array(nil)

        # > If v is a vertex,
        # > inblossom[v] is the top-level blossom to which v belongs.
        # > If v is a top-level vertex, v is itself a blossom (a trivial blossom)
        # > and inblossom[v] == v.
        # > Initially all vertices are top-level trivial blossoms.
        # > (van Rantwijk, mwmatching.py)
        #
        @in_blossom = (0 ... g.num_vertices).to_a

        # > If v is a free vertex (or an unreached vertex inside a T-blossom),
        # > bestedge[v] is the edge to an S-vertex with least slack,
        # > or -1 if there is no such edge.
        # > If b is a (possibly trivial) top-level S-blossom,
        # > bestedge[b] is the least-slack edge to a different S-blossom,
        # > or -1 if there is no such edge.
        # > This is used for efficient computation of delta2 and delta3.
        # > (van Rantwijk, mwmatching.py)
        #
        @best_edge = rantwijk_array(nil)

        # > If b is a non-trivial top-level S-blossom,
        # > blossombestedges[b] is a list of least-slack edges to neighbouring
        # > S-blossoms, or None if no such list has been computed yet.
        # > This is used for efficient computation of delta3.
        # > (van Rantwijk, mwmatching.py, line 168)
        #
        @blossom_best_edges = rantwijk_array(nil)

        # Queue of newly discovered S-vertices.
        @queue = []

        # A 2D array representing a tree of blossoms.
        #
        # > The blossom structure of a graph is represented by a
        # > *blossom tree*.  Its nodes are the graph G, the blossoms
        # > of G, and all vertices included in blossoms.  The root is
        # > G, whose children are the maximal blossoms.  ..  Any
        # > vertex is a leaf.
        # > (Gabow, 1985, p. 91)
        #
        # van Rantwijk implements the blossom tree with an array in
        # two halves.  The first half is "trivial" blossoms, vertexes,
        # the leaves of the tree.  The second half are non-trivial blossoms.
        #
        # > Vertices are numbered 0 .. (nvertex-1).
        # > Non-trivial blossoms are numbered nvertex .. (2*nvertex-1)
        # > (van Rantwijk, mwmatching.py, line 58)
        #
        # > If b is a non-trivial (sub-)blossom,
        # > blossomchilds[b] is an ordered list of its sub-blossoms, starting with
        # > the base and going round the blossom.
        # > (van Rantwijk, mwmatching.py, line 147)
        #
        @blossom_children = rantwijk_array(nil)

        # Optimization: Cache of tight (zero slack) edges.  *Tight*
        # is a term I attribute to Gabow, though it may be earlier.
        #
        # > Edge ij is *tight* if equality holds in [its dual
        # > value function]. (Gabow, 1985, p. 91)
        #
        # Van Rantwijk calls this cache `allowedge`, denoting its use
        # in the algorithm.
        #
        # > If allowedge[k] is true, edge k has zero slack in the optimization
        # > problem; if allowedge[k] is false, the edge's slack may or may not
        # > be zero.
        @tight_edge = Array.new(g.num_edges, false)
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

        # Iterative *stages*.  Each stage augments the matching.
        # There can be at most n stages, where n is num. vertexes.
        while true do
          init_stage

          # *sub-stages* either augment or scale the duals.
          augmented = false
          while true do
            log(1, "substage")

            # > The search is conducted by scanning the S-vertices in turn.
            # > Scanning a vertex means considering in turn all its edges
            # > except the matched edge. (There will be at most one).
            # > (Galil, 1986, p. 26)
            until augmented || queue.empty?
              v = queue.pop
              log(2, "scan #{v}")
              assert_label(v, LBL_S)

              neighb_end[v].each do |p|
                k = p / 2 # note: floor division
                w = endpoint[p]

                if in_blossom[v] == in_blossom[w]
                  # > this edge is internal to a blossom; ignore it
                  # > (van Rantwijk, mwmatching.py, line 681)
                  next
                end

                kslack = calc_slack(k)

                # > .. we only use edges with π<sub>ij</sub> = 0.
                # > (Galil, 1986, p. 32)
                if tight_edge[k]

                  # > If we scan the S-vertex *i* and consider the edge (i,j),
                  # > there are two cases:
                  # >
                  # > * (C1) j is free; or
                  # > * (C2) j is an S-vertex
                  # >
                  # > C2 cannot occur in the bipartite case.  The case in
                  # > which j is a T-vertex is discarded.
                  # > (Galil, 1986, p. 26-27)
                  #
                  if free?(in_blossom[w])

                    # > (C1) w is a free vertex;
                    # > label w with T and label its mate with S (R12).
                    # > (Van Rantwijk, mwmatching.py, line 690)
                    #
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
                    #
                    assign_label(w, LBL_T, p ^ 1)

                  elsif label[in_blossom[w]] == LBL_S

                    # > (C2) w is an S-vertex (not in the same blossom);
                    # > follow back-links to discover either an
                    # > augmenting path or a new blossom.
                    # > (Van Rantwijk, mwmatching.py, line 694)
                    #
                    # > Backtrack from i and j, using the labels, to the
                    # > single persons s<sub>i</sub> and s<sub>j</sub>
                    # > from which i and j got their S labels.  If
                    # > s<sub>i</sub> ≠ s<sub>j</sub>, we find an augmenting
                    # > path from s<sub>i</sub> to s<sub>j</sub> and augment
                    # > the matching. (Galil, 1986, p. 27)
                    #
                    fail 'not yet implemented'
                    base = scan_blossom(v, w)

                  end # free blossom
                end # tight edge
              end # scan neighbors of `v`
            end # queue
          end # sub-stage
        end # stage

        Matching.gabow(m)
      end

      # Pseudo-private
      # --------------
      #
      # Eventually, these methods will probably be private.  For now,
      # they are public so they can be easily tested.
      #

      def assert_label(v, lbl)
        unless label[in_blossom[v]] == lbl
          raise "Expected vertex #{v} to be labeled #{LBL_NAMES[lbl]}"
        end
      end

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

      # Returns nil if `k` is known to be an endpoint of a tight
      # edge.  Otherwise, calculates and returns the slack of `k`,
      # and updates the `tight_edge` cache.
      def calc_slack(k)
        if tight_edge[k]
          nil
        else
          slack(k).tap { |kslack|
            @tight_edge[k] = true if kslack <= 0
          }
        end
      end

      # TODO: Optimize by de-normalizing
      def free?(x)
        @label[x] == LBL_FREE
      end

      def init_stage
        log(0, "stage. mate = #{mate}")
        init_stage_caches
        @queue = []
        init_stage_labels
      end

      # Clear the van Rantwijk "best edge" caches
      def init_stage_caches
        @best_edge = rantwijk_array(nil)
        @blossom_best_edges.fill(nil, g.num_vertices)
        @tight_edge = Array.new(g.num_edges, false)
      end

      # > We start by labeling all single persons S
      # > (Galil, 1986, p. 26)
      #
      # > Label single blossoms/vertices with S and put them in
      # > the queue. (van Rantwijk, mwmatching.py, line 649)
      def init_stage_labels
        @label = rantwijk_array(LBL_FREE)
        (0 ... g.num_vertices).each do |v|
          if single?(v) && label[in_blossom[v]] == LBL_FREE
            assign_label(v, LBL_S)
          end
        end
        log(1, "labels: #{label}")
      end

      # Returns true if vertex `i` is matched in `mate`.
      # TODO: Optimize by de-normalizing.
      def matched?(i)
        !mate[i].nil?
      end

      # Returns false if vertex `i` is matched in `mate`.
      # TODO: Optimize by de-normalizing.
      def single?(i)
        mate[i].nil?
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

      # Returns an array of size 2n, where n is the number of
      # vertexes.  Common in van Rantwijk's implementation, but
      # the idea may come from Gabow (1985) or earlier.
      def rantwijk_array(fill)
        Array.new(2 * g.num_vertices, fill)
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

      # > We now define slacks π<sub>ij</sub> slightly differently
      # > [compared to problem 3]. (Galil, 1986, p.31)
      def slack(k)
        fail 'not yet implemented'
      end

      def unmatched_adjacent(v, m)
        g.adjacent_vertices(v).select { |i| m[v] != i }
      end

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
