require_relative '../explainable'
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
        mcm_stage(Matching.new, u)
      end

      private

      # Begin each stage (until no augmenting path is found)
      # by clearing all labels and marks
      def mcm_stage(m, u)
        t = LabelSet.new([], 'T')
        marked = LabelSet.new([], 'mark')
        predecessors = Hash.new
        aug_path = nil

        # Label unmatched vertexes in U with label R.  These R-vertexes
        # are candidates for the start of an augmenting path.
        unmarked = r = LabelSet.new(m.unmatched_vertexes_in(u), 'R')

        # While there are unmarked R-vertexes
        while aug_path.nil? && start = unmarked.to_a.sample
          marked.add(start)

          # Follow the unmatched edges (if any) to vertexes in V
          # ignoring any V-vertexes already labeled T
          g.unmatched_unlabled_adjacent_to(start, m, t).each do |vi|
            t.add(vi)
            predecessors[vi] = start

            adj_u = g.vertices_adjacent_to(vi, except: [start])
            if adj_u.empty?
              aug_path = [vi, start]
            else

              # If there are matched edges, follow each to a vertex
              # in U and label the U-vertex with R.  Otherwise,
              # backtrack to construct an augmenting path.
              adj_u_in_m = g.matched_adjacent_to(vi, adj_u, m).each do |ui|
                r.add(ui)
                predecessors[ui] = vi
              end

              if adj_u_in_m.empty?
                aug_path = g.backtrack_from(vi, predecessors)
              end
            end

            break unless aug_path.nil?
          end

          unmarked = r - marked
        end

        aug_path.nil? ? m : mcm_stage(m.augment(aug_path), u)
      end
    end
  end
end
