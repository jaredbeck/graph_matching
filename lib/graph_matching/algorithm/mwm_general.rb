# encoding: utf-8

require_relative '../graph/weighted_graph'
require_relative '../matching'
require_relative 'matching_algorithm'

module GraphMatching
  module Algorithm

    # `MWMGeneral` implements Maximum Weighted Matching in
    # general graphs.
    class MWMGeneral < MatchingAlgorithm

      # > Check delta2/delta3 computation after every substage;
      # > only works on integer weights, slows down the algorithm to O(n^4).
      # > (Van Rantwijk, mwmatching.py, line 34)
      CHECK_DELTA = false

      # If b is a top-level blossom,
      # label[b] is 0 if b is unlabeled (free);
      #             1 if b is an S-vertex/blossom;
      #             2 if b is a T-vertex/blossom.
      LBL_FREE = 0
      LBL_S = 1
      LBL_T = 2
      LBL_CRUMB = 5
      LBL_NAMES = ['Free', 'S', 'T', 'Crumb']

      def initialize(graph)
        assert(graph).is_a(Graph::WeightedGraph)
        super
        init_graph_structures
        init_algorithm_structures
      end

      # > As in Problem 3, the algorithm consists of O(n) *stages*.
      # > In each stage we look for an augmenting path using the
      # > labeling R12 and the two cases C1, C2 as in the simple
      # > algorithm for Problem 2, except that we only use edges
      # > with π<sub>ij</sub> = 0. (Galil, 1986, p. 32)
      #
      # Van Rantwijk's implementation (and, consequently, this port)
      # supports both maximum cardinality maximum weight matching
      # and MWM irrespective of cardinality.
      def match(max_cardinality)
        return Matching.new if g.size < 2

        # Iterative *stages*.  Each stage augments the matching.
        # There can be at most n stages, where n is num. vertexes.
        while true do
          init_stage

          # *sub-stages* either augment or scale the duals.
          augmented = false
          while true do

            # > The search is conducted by scanning the S-vertices
            # > in turn. (Galil, 1986, p. 26)
            until augmented || @queue.empty?
              augmented = scan_vertex(@queue.pop)
            end

            break if augmented

            # > There is no augmenting path under these constraints;
            # > compute delta and reduce slack in the optimization problem.
            # > (Van Rantwijk, mwmatching.py, line 732)
            delta, delta_type, delta_edge, delta_blossom = calc_delta(max_cardinality)
            update_duals(delta)

            # > Take action at the point where minimum delta occurred.
            # > (Van Rantwijk, mwmatching.py)
            case delta_type
            when 1
              # > No further improvement possible; optimum reached.
              break
            when 2
              # > Use the least-slack edge to continue the search.
              @tight_edge[delta_edge] = true
              i, j = @edges[delta_edge].to_a
              if @label[@in_blossom[i]] == LBL_FREE
                i, j = j, i
              end
              assert_label(@in_blossom[i], LBL_S)
              @queue.push(i)
            when 3
              # > Use the least-slack edge to continue the search.
              @tight_edge[delta_edge] = true
              i, j = @edges[delta_edge].to_a
              assert_label(@in_blossom[i], LBL_S)
              @queue.push(i)
            when 4
              # > Expand the least-z blossom.
              expand_blossom(delta_blossom, false)
            else
              raise "Invalid delta_type: #{delta_type}"
            end

          end # sub-stage

          # > Stop when no more augmenting path can be found.
          # > (Van Rantwijk, mwmatching.py)
          break unless augmented

          # > End of a stage; expand all S-blossoms which have dualvar = 0.
          # > (Van Rantwijk, mwmatching.py)
          (@nvertex ... 2 * @nvertex).each do |b|
            if top_level_blossom?(b) && @label[b] == LBL_S && @dual[b] == 0
              expand_blossom(b, true)
            end
          end

        end # stage

        # The stages are complete, and hopefully so is the matching!
        matching = Matching.new
        @mate.each do |p|
          matching.add([@endpoint[p], @endpoint[p ^ 1]]) unless p.nil?
        end
        matching
      end

      private

      # > Construct a new blossom with given base, containing edge
      # > k which connects a pair of S vertices. Label the new
      # > blossom as S; set its dual variable to zero; relabel its
      # > T-vertices to S and add them to the queue.
      # > (Van Rantwijk, mwmatching.py, line 270)
      def add_blossom(base, k)
        v, w = @edges[k].to_a
        bb = @in_blossom[base]
        bv = @in_blossom[v]
        bw = @in_blossom[w]

        # Create a new top-level blossom.
        b = @unused_blossoms.pop
        @blossom_base[b] = base
        @blossom_parent[b] = nil
        @blossom_parent[bb] = b

        # > Make list of sub-blossoms and their interconnecting
        # > edge endpoints.
        # > (Van Rantwijk, mwmatching.py, line 284)
        #
        # 1. Clear the existing lists
        # 2. Trace back from v to base
        # 3. Reverse lists, add endpoint that connects the pair of S vertices
        # 4. Trace back from w to base
        #
        @blossom_children[b] = []
        @blossom_endps[b] = []
        trace_to_base(bv, bb) do |bv|
          @blossom_parent[bv] = b
          @blossom_children[b] << bv
          @blossom_endps[b] << @label_end[bv]
        end
        @blossom_children[b] << bb
        @blossom_children[b].reverse!
        @blossom_endps[b].reverse!
        @blossom_endps[b] << 2 * k
        trace_to_base(bw, bb) do |bw|
          @blossom_parent[bw] = b
          @blossom_children[b] << bw
          @blossom_endps[b] << (@label_end[bw] ^ 1)
        end

        # > Set label to S
        assert(@label[bb]).eq(LBL_S)
        @label[b] = LBL_S
        @label_end[b] = @label_end[bb]

        # > Set dual variable to zero.
        @dual[b] = 0

        # > Relabel vertices.
        blossom_leaves(b).each do |v|
          if @label[@in_blossom[v]] == LBL_T
            # > This T-vertex now turns into an S-vertex because it
            # > becomes part of an S-blossom; add it to the queue.
            @queue << v
          end
          @in_blossom[v] = b
        end

        # > Compute blossombestedges[b].
        best_edge_to = rantwijk_array(nil)
        @blossom_children[b].each do |bv|
          if @blossom_best_edges[bv].nil?
            # > This subblossom [bv] does not have a list of least-
            # > slack edges.  Get the information from the vertices.
            nblists = blossom_leaves(bv).map { |v|
              @neighb_end[v].map { |p|
                p / 2 # floor division
              }
            }
          else
            # > Walk this subblossom's least-slack edges.
            nblists = [@blossom_best_edges[bv]]
          end

          nblists.each do |nblist|
            nblist.each do |k|
              i, j = @edges[k].to_a
              if @in_blossom[j] == b
                i, j = j, i
              end
              bj = @in_blossom[j]
              if bj != b &&
                  @label[bj] == LBL_S &&
                  (best_edge_to[bj] == nil || slack(k) < slack(best_edge_to[bj]))
                best_edge_to[bj] = k
              end
            end
          end

          # > Forget about least-slack edges of the subblossom.
          @blossom_best_edges[bv] = nil
          @best_edge[bv] = nil
        end

        @blossom_best_edges[b] = best_edge_to.compact

        # > Select bestedge[b]
        @best_edge[b] = nil
        @blossom_best_edges[b].each do |k|
          if @best_edge[b].nil? || slack(k) < slack(@best_edge[b])
            @best_edge[b] = k
          end
        end
      end

      def assert_blossom_trace(b)
        t = @label[b] == LBL_T
        s = @label[b] == LBL_S
        m = @label_end[b] == @mate[@blossom_base[b]]
        unless t || s && m
          raise <<-EOS
              Assertion failed: Expected either:
              1. Current Bv to be a T-blossom, or
              2. Bv is an S-blossom and its base is matched to @label_end[bv]
          EOS
        end
      end

      def assert_label(ix, lbl)
        unless @label[ix] == lbl
          raise "Expected label at #{ix} to be #{LBL_NAMES[lbl]}"
        end
      end

      # > Assign label t to the top-level blossom containing vertex w
      # > and record the fact that w was reached through the edge with
      # > remote endpoint p.
      # > (Van Rantwijk, mwmatching.py)
      #
      def assign_label(w, t, p = nil)
        b = @in_blossom[w]
        assert_label(w, LBL_FREE)
        assert_label(b, LBL_FREE)
        @label[w] = @label[b] = t
        @label_end[w] = @label_end[b] = p
        @best_edge[w] = @best_edge[b] = nil
        if t == LBL_S
          # b became an S-vertex/blossom; add it(s vertices) to the queue.
          @queue.concat(blossom_leaves(b))
        elsif t == LBL_T
          # b became a T-vertex/blossom; assign label S to its mate.
          # (If b is a non-trivial blossom, its base is the only vertex
          # with an external mate.)
          base = @blossom_base[b]
          if @mate[base].nil?
            raise "Expected blossom #{b}'s base (#{base}) to be matched"
          end

          # Assign label S to the mate of blossom b's base.
          # Remember, `mate` elements are pointers to "endpoints".
          # The bitwise XOR is very clever. `mate[x]` and `mate[x] ^ 1`
          # are connected "endpoints".
          base_edge_endpoints = [@mate[base], @mate[base] ^ 1]
          assign_label(@endpoint[base_edge_endpoints[0]], LBL_S, base_edge_endpoints[1])
        else
          raise ArgumentError, "Unexpected label: #{t}"
        end
      end

      # > Swap matched/unmatched edges over an alternating path
      # > through blossom b between vertex v and the base vertex.
      # > Keep blossom bookkeeping consistent.
      # > (Van Rantwijk, mwmatching.py, line 448)
      def augment_blossom(b, v)
        t = immediate_subblossom_of(b, v)

        # > Recursively deal with the first sub-blossom.
        if t >= @nvertex
          augment_blossom(t, v)
        end

        # > Move along the blossom until we get to the base.
        j, jstep, endptrick = blossom_loop_direction(b, t)
        i = j
        while j != 0
          # > Step to the next sub-blossom and augment it recursively.
          j += jstep
          p = @blossom_endps[b][j - endptrick] ^ endptrick
          x = @endpoint[p]
          augment_blossom_step(b, j, x)

          # > Step to the next sub-blossom and augment it recursively.
          j += jstep
          x = @endpoint[p ^ 1]
          augment_blossom_step(b, j, x)

          # > Match the edge connecting those sub-blossoms.
          match_endpoint(p)
        end

        # > Rotate the list of sub-blossoms to put the new base at
        # > the front.
        @blossom_children[b].rotate!(i)
        @blossom_endps[b].rotate!(i)
        @blossom_base[b] = @blossom_base[@blossom_children[b][0]]
        assert(@blossom_base[b]).eq(v)
      end

      def augment_blossom_step(b, j, x)
        t = @blossom_children[b][j]
        if t >= @nvertex
          augment_blossom(t, x)
        end
      end

      # > Swap matched/unmatched edges over an alternating path
      # > between two single vertices. The augmenting path runs
      # > through edge k, which connects a pair of S vertices.
      # > (Van Rantwijk, mwmatching.py, line 494)
      def augment_matching(k)
        v, w = @edges[k].to_a
        [[v, 2 * k + 1], [w, 2 * k]].each do |(s, p)|
          # > Match vertex s to remote endpoint p. Then trace back from s
          # > until we find a single vertex, swapping matched and unmatched
          # > edges as we go.
          # > (Van Rantwijk, mwmatching.py, line 504)
          while true
            bs = @in_blossom[s]
            assert_label(bs, LBL_S)
            assert(@label_end[bs]).eq(@mate[@blossom_base[bs]])
            # > Augment through the S-blossom from s to base.
            if bs >= @nvertex
              augment_blossom(bs, s)
            end
            @mate[s] = p
            # > Trace one step back.
            # If we reach a single vertex, stop
            break if @label_end[bs].nil?
            t = @endpoint[@label_end[bs]]
            bt = @in_blossom[t]
            assert_label(bt, LBL_T)
            # > Trace one step back.
            assert(@label_end[bt]).not_nil
            s = @endpoint[@label_end[bt]]
            j = @endpoint[@label_end[bt] ^ 1]
            # > Augment through the T-blossom from j to base.
            assert(@blossom_base[bt]).eq(t)
            if bt >= @nvertex
              augment_blossom(bt, j)
            end
            @mate[j] = @label_end[bt]
            # > Keep the opposite endpoint;
            # > it will be assigned to mate[s] in the next step.
            p = @label_end[bt] ^ 1
          end
        end
      end

      # TODO: Optimize by returning lazy iterator
      def blossom_leaves(b, ary = [])
        if b < @nvertex
          ary.push(b)
        else
          @blossom_children[b].each do |c|
            if c < @nvertex
              ary.push(c)
            else
              ary.concat(blossom_leaves(c))
            end
          end
        end
        ary
      end

      # > Decide in which direction we will go round the blossom.
      # > (Van Rantwijk, mwmatching.py, lines 385, 460)
      def blossom_loop_direction(b, t)
        j = @blossom_children[b].index(t)
        if j.odd?
          # > go forward and wrap
          j -= @blossom_children[b].length
          jstep = 1
          endptrick = 0
        else
          # > go backward
          jstep = -1
          endptrick = 1
        end
        return j, jstep, endptrick
      end

      def calc_delta(max_cardinality)
        delta = nil
        delta_type = nil
        delta_edge = nil
        delta_blossom = nil

        # > Verify data structures for delta2/delta3 computation.
        # > (Van Rantwijk, mwmatching.py, line 739)
        if CHECK_DELTA
          check_delta2
          check_delta3
        end

        # > Compute delta1: the minumum value of any vertex dual.
        # > (Van Rantwijk, mwmatching.py)
        if !max_cardinality
          delta_type = 1
          delta = @dual[0, @nvertex].min
        end

        # > Compute delta2: the minimum slack on any edge between
        # > an S-vertex and a free vertex.
        # > (Van Rantwijk, mwmatching.py)
        (0 ... @nvertex).each do |v|
          if @label[@in_blossom[v]] == LBL_FREE && !@best_edge[v].nil?
            d = slack(@best_edge[v])
            if delta_type == nil || d < delta
              delta = d
              delta_type = 2
              delta_edge = @best_edge[v]
            end
          end
        end

        # > Compute delta3: half the minimum slack on any edge between
        # > a pair of S-blossoms.
        # > (Van Rantwijk, mwmatching.py)
        (0 ... 2 * @nvertex).each do |b|
          if @blossom_parent[b].nil? && @label[b] == LBL_S && !@best_edge[b].nil?
            kslack = slack(@best_edge[b])
            d = kslack / 2 # Van Rantwijk had some type checking here.  Why?
            if delta_type.nil? || d < delta
              delta = d
              delta_type = 3
              delta_edge = @best_edge[b]
            end
          end
        end

        # > Compute delta4: minimum z variable of any T-blossom.
        # > (Van Rantwijk, mwmatching.py)
        (@nvertex ... 2 * @nvertex).each do |b|
          top_t_blossom = top_level_blossom?(b) && @label[b] == LBL_T
          if top_t_blossom && (delta_type.nil? || @dual[b] < delta)
            delta = @dual[b]
            delta_type = 4
            delta_blossom = b
          end
        end

        if delta_type.nil?
          # > No further improvement possible; max-cardinality optimum
          # > reached. Do a final delta update to make the optimum
          # > verifyable.
          # > (Van Rantwijk, mwmatching.py)
          assert(max_cardinality).eq(true)
          delta_type = 1
          delta = [0, @dual[0, @nvertex].min].max
        end

        return delta, delta_type, delta_edge, delta_blossom
      end

      # Returns nil if `k` is known to be an endpoint of a tight
      # edge.  Otherwise, calculates and returns the slack of `k`,
      # and updates the `tight_edge` cache.
      def calc_slack(k)
        if @tight_edge[k]
          nil
        else
          slack(k).tap { |kslack|
            @tight_edge[k] = true if kslack <= 0
          }
        end
      end

      # > Check optimized delta2 against a trivial computation.
      # > (Van Rantwijk, mwmatching.py, line 580)
      def check_delta2
        (0 ... @nvertex).each do |v|
          if @label[@in_blossom[v]] == LBL_FREE
            bd = nil
            bk = nil
            @neighb_end[v].each do |p|
              k = p / 2 # Note: floor division
              w = @endpoint[p]
              if @label[@in_blossom[w]] == LBL_S
                d = slack(k)
                if bk.nil? || d < bd
                  bk = k
                  bd = d
                end
              end
            end
            option1 = bk.nil? && @best_edge[v].nil?
            option2 = !@best_edge[v].nil? && bd == slack(@best_edge[v])
            unless option1 || option2
              raise "Assertion failed: Free vertex #{v}"
            end
          end
        end
      end

      # > Check optimized delta3 against a trivial computation.
      # > (Van Rantwijk, mwmatching.py, line 598)
      def check_delta3
        bk = nil
        bd = nil
        tbk = nil
        tbd = nil
        (0 ... 2 * @nvertex).each do |b|
          if @blossom_parent[b].nil? && @label[b] == LBL_S
            blossom_leaves(b).each do |v|
              @neighb_end[v].each do |p|
                k = p / 2 # Note: floor division
                w = @endpoint[p]
                if @in_blossom[w] != b && @label[@in_blossom[w]] == LBL_S
                  d = slack(k)
                  if bk.nil? || d < bd
                    bk = k
                    bd = d
                  end
                end
              end
            end
            if !@best_edge[b].nil?
              i, j = @edges[@best_edge[b]].to_a
              unless @in_blossom[i] == b || @in_blossom[j] == b
                raise 'Assertion failed'
              end
              unless @in_blossom[i] != b || @in_blossom[j] != b
                raise 'Assertion failed'
              end
              unless @label[@in_blossom[i]] == LBL_S && @label[@in_blossom[j]] == LBL_S
                raise 'Assertion failed'
              end
              if tbk.nil? || slack(@best_edge[b]) < tbd
                tbk = @best_edge[b]
                tbd = slack(@best_edge[b])
              end
            end
          end
        end
        unless bd == tbd
          raise 'Assertion failed'
        end
      end

      # > w is a free vertex (or an unreached vertex inside
      # > a T-blossom) but we can not reach it yet;
      # > keep track of the least-slack edge that reaches w.
      # > (Van Rantwijk, mwmatching.py, line 725)
      def consider_loose_edge_to_free_vertex(w, k, kslack)
        if @best_edge[w].nil? || kslack < slack(@best_edge[w])
          @best_edge[w] = k
        end
      end

      # While scanning neighbors of `v`, a loose edge to an
      # S-blossom is found, and the `@best_edge` cache may
      # be updated.
      #
      # > keep track of the least-slack non-allowable [loose] edge
      # > to a different S-blossom.
      # > (Van Rantwijk, mwmatching.py, line 717)
      #
      def consider_loose_edge_to_s_blossom(v, k, kslack)
        b = @in_blossom[v]
        if @best_edge[b].nil? || kslack < slack(@best_edge[b])
          @best_edge[b] = k
        end
      end

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
      def consider_tight_edge(k, w, p, v)
        augmented = false

        if @label[@in_blossom[w]] == LBL_FREE

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

        elsif @label[@in_blossom[w]] == LBL_S

          # > (C2) w is an S-vertex (not in the same blossom);
          # > follow back-links to discover either an
          # > augmenting path or a new blossom.
          # > (Van Rantwijk, mwmatching.py, line 694)
          #
          base = scan_blossom(v, w)
          if base.nil?
            # > Found an augmenting path; augment the
            # > matching and end this stage.
            # > (Van Rantwijk, mwmatching.py, line 703)
            augment_matching(k)
            augmented = true
          else
            # > Found a new blossom; add it to the blossom
            # > bookkeeping and turn it into an S-blossom.
            # > (Van Rantwijk, mwmatching.py, line 699)
            add_blossom(base, k)
          end

        elsif @label[w] == LBL_FREE

          # > w is inside a T-blossom, but w itself has not
          # > yet been reached from outside the blossom;
          # > mark it as reached (we need this to relabel
          # > during T-blossom expansion).
          # > (Van Rantwijk, mwmatching.py, line 709)
          #
          assert_label(@in_blossom[w], LBL_T)
          @label[w] = LBL_T
          @label_end[w] = p ^ 1

        end

        augmented
      end

      # > Expand the given top-level blossom.
      # > (Van Rantwijk, mwmatching.py, line 361)
      #
      # Blossoms are expanded during slack adjustment delta type 4,
      # and after all stages are complete (endstage will be true).
      #
      def expand_blossom(b, endstage)
        promote_sub_blossoms_of(b, endstage)

        # > If we expand a T-blossom during a stage, its sub-blossoms
        # > must be relabeled.
        if !endstage && @label[b] == LBL_T
          expand_t_blossom(b)
        end

        recycle_blossom_number(b)
      end

      # > Start at the sub-blossom through which the expanding
      # > blossom obtained its label, and relabel sub-blossoms until
      # > we reach the base.
      # > Figure out through which sub-blossom the expanding blossom
      # > obtained its label initially.
      # > (Van Rantwijk, mwmatching.py, line 378)
      def expand_t_blossom(b)
        assert(@label_end[b]).not_nil
        entry_child = @in_blossom[@endpoint[@label_end[b] ^ 1]]

        # > Move along the blossom until we get to the base.
        j, jstep, endptrick = blossom_loop_direction(b, entry_child)
        p = @label_end[b]
        while j != 0

          # > Relabel the T-sub-blossom.
          @label[@endpoint[p ^ 1]] = LBL_FREE
          @label[@endpoint[@blossom_endps[b][j - endptrick] ^ endptrick ^ 1]] = LBL_FREE
          assign_label(@endpoint[p ^ 1], LBL_T, p)

          # > Step to the next S-sub-blossom and note its forward endpoint.
          @tight_edge[@blossom_endps[b][j - endptrick] / 2] = true # floor division
          j += jstep
          p = @blossom_endps[b][j - endptrick] ^ endptrick

          # > Step to the next T-sub-blossom.
          @tight_edge[p / 2] = true # floor division
          j += jstep
        end

        # > Relabel the base T-sub-blossom WITHOUT stepping through to
        # > its mate (so don't call assignLabel).
        bv = @blossom_children[b][j]
        @label[@endpoint[p ^ 1]] = @label[bv] = LBL_T
        @label_end[@endpoint[p ^ 1]] = @label_end[bv] = p
        @best_edge[bv] = nil

        # > Continue along the blossom until we get back to entrychild.
        j += jstep
        while @blossom_children[b][j] != entry_child

          # > Examine the vertices of the sub-blossom to see whether
          # > it is reachable from a neighbouring S-vertex outside the
          # > expanding blossom.
          bv = @blossom_children[b][j]
          if @label[bv] == LBL_S
            # > This sub-blossom just got label S through one of its
            # > neighbours; leave it.
            j += jstep
            next
          end

          # > If the sub-blossom contains a reachable vertex, assign
          # > label T to the sub-blossom.
          v = first_labeled_blossom_leaf(bv)
          unless v.nil?
            assert_label(v, LBL_T)
            assert(@in_blossom[v]).eq(bv)
            @label[v] = LBL_FREE
            @label[@endpoint[@mate[@blossom_base[bv]]]] = LBL_FREE
            assign_label(v, LBL_T, @label_end[v])
          end

          j += jstep
        end
      end

      def first_labeled_blossom_leaf(b)
        blossom_leaves(b).find { |leaf| @label[leaf] != LBL_FREE }
      end

      # Starting from a vertex `v`, ascend the blossom tree, and
      # return the sub-blossom immediately below `b`.
      def immediate_subblossom_of(b, v)
        t = v
        while @blossom_parent[t] != b
          t = @blossom_parent[t]
        end
        t
      end

      # Data structures used throughout the algorithm.
      def init_algorithm_structures

        # > If v is a vertex,
        # > mate[v] is the remote endpoint of its matched edge, or -1 if it is single
        # > (i.e. endpoint[mate[v]] is v's partner vertex).
        # > Initially all vertices are single; updated during augmentation.
        # > (Van Rantwijk, mwmatching.py)
        #
        @mate = Array.new(@nvertex, nil)

        # > If b is a top-level blossom,
        # > label[b] is 0 if b is unlabeled (free);
        # >             1 if b is an S-vertex/blossom;
        # >             2 if b is a T-vertex/blossom.
        # > The label of a vertex is found by looking at the label of its
        # > top-level containing blossom.
        # > If v is a vertex inside a T-blossom,
        # > label[v] is 2 iff v is reachable from an S-vertex outside the blossom.
        # > Labels are assigned during a stage and reset after each augmentation.
        # > (Van Rantwijk, mwmatching.py)
        #
        @label = rantwijk_array(LBL_FREE)

        # > If b is a labeled top-level blossom,
        # > labelend[b] is the remote endpoint of the edge through which b obtained
        # > its label, or -1 if b's base vertex is single.
        # > If v is a vertex inside a T-blossom and label[v] == 2,
        # > labelend[v] is the remote endpoint of the edge through which v is
        # > reachable from outside the blossom.
        # > (Van Rantwijk, mwmatching.py)
        #
        @label_end = rantwijk_array(nil)

        # > If v is a vertex,
        # > inblossom[v] is the top-level blossom to which v belongs.
        # > If v is a top-level vertex, v is itself a blossom (a trivial blossom)
        # > and inblossom[v] == v.
        # > Initially all vertices are top-level trivial blossoms.
        # > (Van Rantwijk, mwmatching.py)
        #
        @in_blossom = (0 ... @nvertex).to_a

        # > If b is a sub-blossom,
        # > blossomparent[b] is its immediate parent (sub-)blossom.
        # > If b is a top-level blossom, blossomparent[b] is -1.
        # > (Van Rantwijk, mwmatching.py)
        #
        @blossom_parent = rantwijk_array(nil)

        # A 2D array representing a tree of blossoms.
        #
        # > The blossom structure of a graph is represented by a
        # > *blossom tree*.  Its nodes are the graph G, the blossoms
        # > of G, and all vertices included in blossoms.  The root is
        # > G, whose children are the maximal blossoms.  ..  Any
        # > vertex is a leaf.
        # > (Gabow, 1985, p. 91)
        #
        # Van Rantwijk implements the blossom tree with an array in
        # two halves.  The first half is "trivial" blossoms, vertexes,
        # the leaves of the tree.  The second half are non-trivial blossoms.
        #
        # > Vertices are numbered 0 .. (nvertex-1).
        # > Non-trivial blossoms are numbered nvertex .. (2*nvertex-1)
        # > (Van Rantwijk, mwmatching.py, line 58)
        #
        # > If b is a non-trivial (sub-)blossom,
        # > blossomchilds[b] is an ordered list of its sub-blossoms, starting with
        # > the base and going round the blossom.
        # > (Van Rantwijk, mwmatching.py, line 144)
        #
        @blossom_children = rantwijk_array(nil)

        # > If b is a (sub-)blossom,
        # > blossombase[b] is its base VERTEX (i.e. recursive sub-blossom).
        # > (Van Rantwijk, mwmatching.py, line 153)
        #
        @blossom_base = (0 ... @nvertex).to_a + Array.new(@nvertex, nil)

        # > If b is a non-trivial (sub-)blossom,
        # > blossomendps[b] is a list of endpoints on its connecting edges,
        # > such that blossomendps[b][i] is the local endpoint of blossomchilds[b][i]
        # > on the edge that connects it to blossomchilds[b][wrap(i+1)].
        # > (Van Rantwijk, mwmatching.py, line 147)
        #
        @blossom_endps = rantwijk_array(nil)

        # > If v is a free vertex (or an unreached vertex inside a T-blossom),
        # > bestedge[v] is the edge to an S-vertex with least slack,
        # > or -1 if there is no such edge.
        # > If b is a (possibly trivial) top-level S-blossom,
        # > bestedge[b] is the least-slack edge to a different S-blossom,
        # > or -1 if there is no such edge.
        # > This is used for efficient computation of delta2 and delta3.
        # > (Van Rantwijk, mwmatching.py)
        #
        @best_edge = rantwijk_array(nil)

        # > If b is a non-trivial top-level S-blossom,
        # > blossombestedges[b] is a list of least-slack edges to neighbouring
        # > S-blossoms, or None if no such list has been computed yet.
        # > This is used for efficient computation of delta3.
        # > (Van Rantwijk, mwmatching.py, line 168)
        #
        @blossom_best_edges = rantwijk_array(nil)

        # > List of currently unused blossom numbers.
        # > (Van Rantwijk, mwmatching.py, line 174)
        @unused_blossoms = (@nvertex ... 2 * @nvertex).to_a

        # > If v is a vertex,
        # > dualvar[v] = 2 * u(v) where u(v) is the v's variable in the dual
        # > optimization problem (multiplication by two ensures integer values
        # > throughout the algorithm if all edge weights are integers).
        # > If b is a non-trivial blossom,
        # > dualvar[b] = z(b) where z(b) is b's variable in the dual optimization
        # > problem.
        # > (Van Rantwijk, mwmatching.py, line 177)
        #
        @dual = Array.new(@nvertex, g.max_w) + Array.new(@nvertex, 0)

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

        # Queue of newly discovered S-vertices.
        @queue = []
      end

      # Builds data structures about the graph.  These structures
      # are not modified by the algorithm.
      def init_graph_structures
        @weight = g.weight

        # The size of the array (or part of an array) used for
        # vertexes (as opposed to blossoms) throughout this
        # algorithm.  It is *not*, as one might assume from the
        # name, the number of vertexes in the graph.
        @nvertex = g.max_v.to_i + 1

        # Make a local copy of the edges.  We'll refer to edges
        # by number throughout throughout the algorithm and it's
        # important that the order be consistent.
        @edges = g.edges.to_a

        # In Joris van Rantwijk's implementation, there seems to be
        # a concept of "edge numbers".  His `endpoint` array has two
        # elements for each edge.  His `mate` array "points to" his
        # `endpoint` array.  (See below)  I'm sure there's a reason,
        # but I don't understand yet.
        #
        # > If p is an edge endpoint,
        # > endpoint[p] is the vertex to which endpoint p is attached.
        # > Not modified by the algorithm.
        # > (Van Rantwijk, mwmatching.py, line 93)
        #
        @endpoint = @edges.map { |e| [e.source, e.target] }.flatten

        # > If v is a vertex,
        # > neighbend[v] is the list of remote endpoints of the edges attached to v.
        # > Not modified by the algorithm.
        # > (Van Rantwijk, mwmatching.py, line 98)
        @neighb_end = init_neighb_end(@nvertex, @edges)
      end

      def init_neighb_end(nvertex, edges)
        neighb_end = Array.new(nvertex) { [] }
        edges.each_with_index do |e, k|
          neighb_end[e.source].push(2 * k + 1)
          neighb_end[e.target].push(2 * k)
        end
        neighb_end
      end

      def init_stage
        init_stage_caches
        @queue = []
        init_stage_labels
      end

      # Clear the Van Rantwijk "best edge" caches
      def init_stage_caches
        @best_edge = rantwijk_array(nil)
        @blossom_best_edges.fill(nil, @nvertex)
        @tight_edge = Array.new(g.num_edges, false)
      end

      # > We start by labeling all single persons S
      # > (Galil, 1986, p. 26)
      #
      # > Label single blossoms/vertices with S and put them in
      # > the queue. (Van Rantwijk, mwmatching.py, line 649)
      def init_stage_labels
        @label = rantwijk_array(LBL_FREE)
        (0 ... @nvertex).each do |v|
          if single?(v) && @label[@in_blossom[v]] == LBL_FREE
            assign_label(v, LBL_S)
          end
        end
      end

      # Add endpoint p's edge to the matching.
      def match_endpoint(p)
        @mate[@endpoint[p]] = p ^ 1
        @mate[@endpoint[p ^ 1]] = p
      end

      # > Convert sub-blossoms [of `b`] into top-level blossoms.
      # > (Van Rantwijk, mwmatching.py, line 364)
      def promote_sub_blossoms_of(b, endstage)
        @blossom_children[b].each do |s|
          @blossom_parent[s] = nil
          if s < @nvertex
            @in_blossom[s] = s
          elsif endstage && @dual[s] == 0
            expand_blossom(s, endstage)
          else
            blossom_leaves(s).each do |v|
              @in_blossom[v] = s
            end
          end
        end
      end

      def recycle_blossom_number(b)
        @label[b] = nil
        @label_end[b] = nil
        @blossom_children[b] = nil
        @blossom_endps[b] = nil
        @blossom_base[b] = nil
        @blossom_best_edges[b] = nil
        @best_edge[b] = nil
        @unused_blossoms.push(b)
      end

      # Backtrack to find an augmenting path (returns nil) or the
      # base of a new blossom (returns base).
      #
      # > Backtrack from i and j, using the labels, to the
      # > single persons s<sub>i</sub> and s<sub>j</sub>
      # > from which i and j got their S labels.  If
      # > s<sub>i</sub> ≠ s<sub>j</sub>, we find an augmenting
      # > path from s<sub>i</sub> to s<sub>j</sub> and augment
      # > the matching. (Galil, 1986, p. 27)
      #
      # > Trace back from vertices v and w to discover either a new
      # > blossom or an augmenting path. Return the base vertex of
      # > the new blossom or -1. (Van Rantwijk, mwmatching.py, line 233)
      def scan_blossom(v, w)
        # > Trace back from v and w, placing breadcrumbs as we go.
        path = []
        base = nil
        until v.nil? && w.nil?
          # > Look for a breadcrumb in v's blossom or put a new breadcrumb.
          b = @in_blossom[v]
          if @label[b] & 4 != 0
            base = @blossom_base[b]
            break
          end
          assert_label(b, LBL_S)
          path.push(b)
          @label[b] = LBL_CRUMB
          # > Trace one step back.
          assert(@label_end[b]).eq(@mate[@blossom_base[b]])
          if @label_end[b].nil?
            # > The base of blossom b is single; stop tracing this path.
            v = nil
          else
            v = @endpoint[@label_end[b]]
            b = @in_blossom[v]
            assert_label(b, LBL_T)
            # > b is a T-blossom; trace one more step back.
            assert(@label_end[b]).not_nil
            v = @endpoint[@label_end[b]]
          end

          # > Swap v and w so that we alternate between both paths.
          unless w.nil?
            v, w = w, v
          end
        end

        # > Remove breadcrumbs
        path.each do |b| @label[b] = LBL_S end

        base
      end

      # Returns false if vertex `i` is matched in `mate`.
      # TODO: Optimize by de-normalizing.
      def single?(i)
        @mate[i].nil?
      end

      # Trace a path around a blossom, from sub-blossom `bx` to
      # blossom base `bb`, by following `@label_end`.  At each
      # step, `yield` the sub-blossom `bx`.
      def trace_to_base(bx, bb)
        while bx != bb
          yield bx
          assert_blossom_trace(bx)
          assert(@label_end[bx]).not_nil
          bx = @in_blossom[@endpoint[@label_end[bx]]]
        end
      end

      # Returns an array of size 2n, where n is the number of
      # vertexes.  Common in Van Rantwijk's implementation, but
      # the idea may come from Gabow (1985) or earlier.
      def rantwijk_array(fill)
        Array.new(2 * @nvertex, fill)
      end

      # > Scanning a vertex means considering in turn all its edges
      # > except the matched edge. (There will be at most one).
      # > (Galil, 1986, p. 26)
      def scan_vertex(v)
        assert_label(@in_blossom[v], LBL_S)
        augmented = false

        @neighb_end[v].each do |p|
          k = p / 2 # floor division
          w = @endpoint[p]

          if @in_blossom[v] == @in_blossom[w]
            # > this edge is internal to a blossom; ignore it
            # > (Van Rantwijk, mwmatching.py, line 681)
            next
          end

          # Calculate slack of `k`'s edge and update tight_edge cache.
          kslack = calc_slack(k)

          # > .. we only use edges with π<sub>ij</sub> = 0.
          # > (Galil, 1986, p. 32)
          if @tight_edge[k]
            augmented = consider_tight_edge(k, w, p, v)
            break if augmented
          elsif @label[@in_blossom[w]] == LBL_S
            consider_loose_edge_to_s_blossom(v, k, kslack)
          elsif @label[w] == LBL_FREE
            consider_loose_edge_to_free_vertex(w, k, kslack)
          end
        end

        augmented
      end

      # Van Rantwijk's implementation of slack does not match Galil's.
      #
      # > Return 2 * slack of edge k (does not work inside blossoms).
      # > (Van Rantwijk, mwmatching.py, line 194)
      #
      def slack(k)
        i, j = @edges[k].to_a
        @dual[i] + @dual[j] - 2 * @weight[i - 1][j - 1]
      end

      def top_level_blossom?(b)
        !@blossom_base[b].nil? && @blossom_parent[b].nil?
      end

      # > .. we make the following changes in the dual
      # > variables. (Galil, 1986, p. 32)
      def update_duals(delta)
        (0 ... @nvertex).each do |v|
          case @label[@in_blossom[v]]
          when LBL_S
            @dual[v] -= delta
          when LBL_T
            @dual[v] += delta
          else
            # No change to free vertexes
          end
        end
        (@nvertex ... 2 * @nvertex).each do |b|
          if top_level_blossom?(b)
            case @label[b]
            when LBL_S
              @dual[b] += delta
            when LBL_T
              @dual[b] -= delta
            else
              # No change to free blossoms
            end
          end
        end
      end

    end
  end
end
