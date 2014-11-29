require_relative '../matching'
require_relative 'matching_algorithm'

module GraphMatching
  module Algorithm

    # `MCMBipartite` implements Maximum Cardinality Matching in
    # bipartite graphs.
    class MWMBipartite < MatchingAlgorithm

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

        fail 'WIP'

        # For each stage
          # Clear all labels and marks
          # Label all single dogs with S

          # While searching
            # For each i in S
              # For each edge i,j with π (slack) of 0
                # If j is single and free (unlabeled)
                  # backtrack to build an augmenting path
                  # augment m
                # If j is labeled by T
                  # follow matched edges to free dogs, label them by S
            # The search failed
            # Adjust the duals
              # d1 = min of S-dog duals
              # d2 = min of S-dog, free-cat slacks
              # d = min(d1, d2)
              # subtract d from S-dog duals
              # add d to T-cat duals

        Matching.gabow(m)
      end

      private

      # `π` returns the "slack" of an edge (Galil, 1986, p.30)
      def π(g, u, i, j)
        u[i] + u[j] - g.w(i, j)
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
