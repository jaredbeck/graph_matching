require_relative '../matching'
require_relative 'matching_algorithm'

module GraphMatching
  module Algorithm

    # `MWMBipartite` implements Maximum Weighted Matching in
    # bipartite graphs.  It extends Maximum Cardinality
    # Matching for `Weighted` graphs.
    class MWMBipartite < MCMBipartite

      def initialize(graph)
        assert_weighted_bipartite graph
        super
      end

      def match
        m = []
        dogs, cats = g.partition

        # Initialize the "dual" values
        u = []
        ui = g.max_w
        dogs.each do |i| u[i] = ui end
        cats.each do |j| u[j] = 0 end

        # For each stage
        while true do

          # Clear all labels and marks
          # Label all single dogs with S
          aug_path = nil
          predecessors = {}
          t = Set.new
          s = Set.new(dogs) - m
          q = s.dup.to_a

          # While searching
          while aug_path.nil? && i = q.pop do

            # Follow the unmatched edges (if any) to free (unlabeled)
            # cats.  Only consider edges with slack (π) of 0.
            unlabeled_across_unmatched_edges_from(i, g, m ,t).each do |j|
              if π(g, u, i, j) == 0
                t << j
                predecessors[j] = i

                # If there are matched edges, follow each to a dog and
                # label the dog with S.  Otherwise, backtrack to
                # construct an augmenting path.
                m_dogs = matched_adjacent(from: j, except: i, g: g, m: m)

                m_dogs.each do |md|
                  s << md
                  predecessors[md] = j
                end

                if m_dogs.empty?
                  aug_path = backtrack_from(j, predecessors)
                  break
                end
              end
            end
          end

          # We have looked at every S-dog.
          # If no `aug_path` was found, the search failed.
          # Adjust the duals and search again.
          if aug_path.nil?

            # d1 = min of S-dog duals
            d1 = u.values_at(*s).min

            # d2 = min of S-dog, free-cat slacks
            d2 = s.inject([]) { |slacks, s_dog|
              free_cats = g.adjacent_vertices(s_dog).reject { |cat| t.include?(cat) }
              slacks.concat free_cats.map { |free_cat| π(g, u, s_dog, free_cat) }
            }.min

            d = [d1, d2].compact.min

            # If d == d1, then the smallest dual is equal to the
            # smallest slack, and the duals of all single dogs are
            # zero.  Therefore, we're totally done.
            #
            # Otherwise, adjust the duals by subtracting d from S-dog
            # duals and adding d to T-cat duals.
            if d == d1
              break
            else
              s.each do |si| u[si] = u[si] - d end
              t.each do |ti| u[ti] = u[ti] + d end
            end

          else
            m = augment(m, aug_path)
          end
        end

        Matching.gabow(m)
      end

      private

      # `π` returns the "slack" of an edge (Galil, 1986, p.30)
      # Think of "slack" as the difference between the duals of an
      # edge and its weight.
      def π(g, u, i, j)
        u[i] + u[j] - g.w([i, j])
      end

      def assert_weighted_bipartite(graph)
        unless weighted_bipartite?(graph)
          raise ArgumentError, 'Expected a weighted bipartite graph'
        end
      end

      def weighted_bipartite?(graph)
        graph.respond_to?(:partition) && graph.respond_to?(:w)
      end

    end
  end
end
