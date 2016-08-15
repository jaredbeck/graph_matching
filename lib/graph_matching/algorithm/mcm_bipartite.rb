# encoding: utf-8

require_relative '../matching'
require_relative 'matching_algorithm'

module GraphMatching
  module Algorithm

    # `MCMBipartite` implements Maximum Cardinality Matching in
    # bipartite graphs.
    class MCMBipartite < MatchingAlgorithm

      def initialize(graph)
        assert(graph).is_a(Graph::Bigraph)
        super
      end

      def match
        u, v = g.partition
        m = []

        while true

          # Begin each stage by clearing all labels and marks
          t = []
          predecessors = {}
          aug_path = nil

          # Label unmatched vertexes in U with label R.  These R-vertexes
          # are candidates for the start of an augmenting path.
          unmarked = r = u.select { |i| m[i] == nil }

          # While there are unmarked R-vertexes
          while aug_path.nil? && start = unmarked.pop

            # Follow the unmatched edges (if any) to vertexes in V
            # ignoring any V-vertexes already labeled T
            unlabeled_across_unmatched_edges_from(start, g, m, t).each do |vi|
              t << vi
              predecessors[vi] = start

              # If there are matched edges, follow each to a vertex
              # in U and label the U-vertex with R.  Otherwise,
              # backtrack to construct an augmenting path.
              adj_u_in_m = matched_adjacent(vi, start, g, m)

              adj_u_in_m.each do |ui|
                r << ui
                predecessors[ui] = vi
              end

              if adj_u_in_m.empty?
                aug_path = backtrack_from(vi, predecessors)
                break
              end
            end
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

      def assert_valid_aug_path(path)
        unless path.length >= 2 && path.length.even?
          raise 'Invalid augmenting path'
        end
      end

      def augment(m, path)
        assert_valid_aug_path(path)
        ix = 0
        while ix < path.length
          i = path[ix]
          j = path[ix + 1]
          mi = m[i]
          mj = m[j]
          m[mi] = nil unless mi == nil
          m[mj] = nil unless mj == nil
          m[i] = j
          m[j] = i
          ix += 2
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

      def matched_adjacent(from, except, g, m)
        g.adjacent_vertices(from).select { |i|
          i != except && m[from] == i
        }
      end

      # Look across unmatched edges from `v` to find vertexes
      # not labeled `t`.
      def unlabeled_across_unmatched_edges_from(v, g, m, t)
        g.adjacent_vertices(v).select { |i|
          m[v] != i && !t.include?(i)
        }
      end

    end
  end
end
