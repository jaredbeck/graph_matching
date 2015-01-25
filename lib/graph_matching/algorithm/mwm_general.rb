# encoding: utf-8

require_relative '../graph/weighted_graph'
require_relative '../matching'
require_relative 'matching_algorithm'

module GraphMatching
  module Algorithm

    # `MWMGeneral` implements Maximum Weighted Matching in
    # general graphs.
    class MWMGeneral < MatchingAlgorithm

      def initialize(graph)
        assert(graph).is_a(Graph::WeightedGraph)
        super
      end

      # > As in Problem 3, the algorithm consists of O(n) *stages*.
      # > In each stage we look for an augmenting path using the
      # > labeling R12 and the two cases C1, C2 as in the simple
      # > algorithm for Problem 2, except that we only use edges
      # > with π<sub>ij</sub> = 0. (Galil, 1986, p. 32)
      def match
        return Matching.new if g.size < 2

        m = []
        u = init_vertex_duals
        z = [] # blossom duals
        b = [] # blossoms

        # Iterative *stages*.  In each we look for an augmenting path.
        while true do
          p = nil # augmenting path

          # > We start by labeling all single persons S (Galil, 1986, p. 26)
          s = init_s_labels(m)
          t = {}

          # If all vertexes are matched, we're done!
          break if s.empty?

          # > The search is conducted by scanning the S-vertices in turn.
          # > Scanning a vertex means considering in turn all its edges
          # > except the matched edge. (There will be at most one).
          # > (Galil, 1986, p. 26)
          scan = s.keys.dup
          scan.each do |i|
            adj = unmatched_adjacent(i, m)

            # > we only use edges with π<sub>ij</sub> = 0. (Galil, 1986, p. 32)
            adj.each do |j|
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
                if !matched?(i, j, m) && s.key?(i) && free?(j, [s, t])
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
                  p = [i, j]
                elsif back_i != back_j
                  p = backtrack(j, s)
                else
                  fail 'Not yet implemented: blossom shrinking'
                end

              end

              break unless p.nil?
            end

            break unless p.nil?
          end

          if p.nil?
            fail 'Not yet implemented: scale the duals'
          else
            augment(m, p)
          end
        end

        Matching.gabow(m)
      end

      private

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

      def free?(i, label_sets)
        label_sets.none? { |set| set.key?(i) }
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

      def matched?(i, j, m)
        !m[i].nil? && !m[j].nil? && m[i] == j && m[j] == i
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
          inject(0) { |sum, k| sum + k.dual }
      end
    end
  end
end
