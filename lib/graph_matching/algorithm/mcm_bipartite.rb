require_relative '../label_set'
require_relative '../matching'
require_relative 'matching_algorithm'

module GraphMatching
  module Algorithm

    # `MCMBipartite` implements Maximum Cardinality Matching in
    # bipartite graphs.
    class MCMBipartite < MatchingAlgorithm

      def initialize(graph)
        raise ArgumentError unless graph.is_a?(GraphMatching::BipartiteGraph)
        super
      end

      def match
        u, v = g.partition
        m = mcm_stage([], u)
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

      def backtrack_from(end_vertex, predecessors)
        augmenting_path = [end_vertex]
        while predecessors.has_key?(augmenting_path.last)
          augmenting_path.push(predecessors[augmenting_path.last])
        end
        augmenting_path
      end

      # Begin each stage (until no augmenting path is found)
      # by clearing all labels and marks
      def mcm_stage(m, u)
        t = LabelSet.new([], 'T')
        marked = LabelSet.new([], 'mark')
        predecessors = Hash.new
        aug_path = nil

        # Label unmatched vertexes in U with label R.  These R-vertexes
        # are candidates for the start of an augmenting path.
        r_vertexes = u.select { |i| m[i].nil? }
        unmarked = r = LabelSet.new(r_vertexes, 'R')

        # While there are unmarked R-vertexes
        while aug_path.nil? && start = unmarked.to_a.sample
          marked.add(start)

          # Follow the unmatched edges (if any) to vertexes in V
          # ignoring any V-vertexes already labeled T
          g.adjacent_vertices(start).select { |i|
            m[start] != i && !t.include?(i)
          }.each do |vi|
            t.add(vi)
            predecessors[vi] = start

            adj_u = g.adjacent_vertices(vi) - [start]
            if adj_u.empty?
              aug_path = [vi, start]
            else

              # If there are matched edges, follow each to a vertex
              # in U and label the U-vertex with R.  Otherwise,
              # backtrack to construct an augmenting path.
              adj_u_in_m = adj_u.select { |i| m[vi] == i }.each do |ui|
                r.add(ui)
                predecessors[ui] = vi
              end

              if adj_u_in_m.empty?
                aug_path = backtrack_from(vi, predecessors)
              end
            end

            break unless aug_path.nil?
          end

          unmarked = r - marked
        end

        aug_path.nil? ? m : mcm_stage(augment(m, aug_path), u)
      end
    end
  end
end
