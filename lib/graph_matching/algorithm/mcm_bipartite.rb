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
        m = []

        while true
          t = []
          marked = []
          predecessors = {}
          aug_path = nil

          # Label unmatched vertexes in U with label R.  These R-vertexes
          # are candidates for the start of an augmenting path.
          unmarked = r = u.select { |i| m[i].nil? }

          # While there are unmarked R-vertexes
          while aug_path.nil? && start = unmarked.sample
            marked << start

            # Follow the unmatched edges (if any) to vertexes in V
            # ignoring any V-vertexes already labeled T
            g.adjacent_vertices(start).select { |i|
              m[start] != i && !t.include?(i)
            }.each do |vi|
              t << vi
              predecessors[vi] = start

              # If there are matched edges, follow each to a vertex
              # in U and label the U-vertex with R.  Otherwise,
              # backtrack to construct an augmenting path.
              adj_u_in_m = matched_adjacent(from: vi, except: start, g: g, m: m)

              adj_u_in_m.each do |ui|
                r << ui
                predecessors[ui] = vi
              end

              if adj_u_in_m.empty?
                aug_path = backtrack_from(vi, predecessors)
                break
              end
            end

            unmarked = r - marked
          end

          if aug_path.nil?
            break
          else
            m = augment(m, aug_path)
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

      def backtrack_from(end_vertex, predecessors)
        augmenting_path = [end_vertex]
        while predecessors.has_key?(augmenting_path.last)
          augmenting_path.push(predecessors[augmenting_path.last])
        end
        augmenting_path
      end

      # Begin each stage (until no augmenting path is found)
      # by clearing all labels and marks

      def matched_adjacent(from:, except:, g:, m:)
        g.adjacent_vertices(from).select { |i| i != except && m[from] == i }
      end

    end
  end
end
