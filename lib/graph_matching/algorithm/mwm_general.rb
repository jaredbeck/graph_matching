require_relative '../matching'
require_relative 'matching_algorithm'

module GraphMatching
  module Algorithm

    # `MWMGeneral` implements Maximum Weighted Matching in
    # general graphs.
    class MWMGeneral < MatchingAlgorithm

      # > .. an augmenting path whose edges are tight.
      # > (Gabow, 1985, p. 92)
      class WeightedAugmentingPath
      end

      # > Now we introduce the notion of a shell.  In a complete
      # > structured matching, if B is a blossom with a descendant
      # > C, the graph induced on B-C is a shell. (Gabow, 1985, p. 92)
      class Shell
      end

      # > The blossom structure of a graph .. Its nodes are the
      # > graph G, the blossoms of G, and all vertices included in
      # > blossoms.  The root is G, whose children are the maximal
      # > blossoms.  The children of a blossom B are its
      # > constituents Bi, 0 <= i <= 2k, as above.  Any vertex is
      # > a leaf.  (Gabow, 1985, p. 91)
      class BlossomTree < RGL::AdjacencyGraph
      end

      # A `StructuredMatching` consists of ..
      #
      # > .. a matching (not necessarily complete), a blossom tree
      # > (for the matching), and dual variables that are dominating
      # > and tight.  In this definition the only odd sets with
      # > positive dual variables are blossoms (of the blossom tree);
      # > a weighted blossom is one that has a positive dual variable.
      # > Also in this definition, the duals y, z are said to be
      # > tight (with respect to the matching and its blossoms) if
      # > all matched edges and all edges of blossom subgraphs are
      # > tight.  Clearly a complete structured matching is a maximum
      # > complete matching. (Gabow, 1985, p. 92)
      class StructuredMatching

        def initialize
          @m = []
          @blossom_tree = BlossomTree.new

          # > Each vertex i has a real-valued dual variable yi
          # > (Gabow, 1985, p. 91)
          @y = []

          # > .. each set B of an odd number of vertices, nB >= 3,
          # > has a nonnegative dual variable zB ..
          # > (Gabow, 1985, p. 91)
          @z = []
        end

        # > These steps [grow, blossom, expand] are repeated until
        # > the search structure is maximal. (Gabow, 1985, p. 92)
        def maximal?
          fail 'not yet implemented'
        end
      end

      def initialize(graph)
        raise ArgumentError unless graph.is_a?(GraphMatching::Graph::WeightedGraph)
        super
        @search_structure = StructuredMatching.new
      end

      def match
        return Matching.new if g.size <= 1
        m = []
        until @search_structure.maximal?
          wap = search
          m = augment(m, wap)
        end
        Matching.gabow(m)
      end

      # > A search does .. steps until it finds a weighted
      # > augmenting path [wap] (Gabow, 1985, p. 92)
      def search
        wap = nil
        while wap.nil?
          build_tight_edges
          if @search_structure.contains_wap?
            fail 'not yet implemented'
          else
            dual_variable_adjustmeent
          end
        end
        wap
      end

      # > The first three types of steps build a search structure of
      # > tight edges. (Gabow, 1985, p. 92)
      def build_tight_edges
        grow
        blossom
        expand
      end

      # > .. a grow step Adds new tight edges to the search
      # > structure (Gabow, 1985, p. 92)
      def grow
        fail 'not yet implemented'
      end

      # > .. a blossom step constructs a new blossom in the
      # > structure (Gabow, 1985, p. 92)
      def blossom
        fail 'not yet implemented'
      end

      # > .. an expand step replaces an unweighted blossom by its
      # > components (Gabow, 1985, p. 92)
      def expand
        fail 'not yet implemented'
      end

      # > This step starts by computing a quantity δ.  The duals of
      # > all free vertices are decreased by δ.  Other duals yi
      # > change by ±δ or zero; zB's change by ±2δ or zero.  The
      # > adjustment keeps the duals dominating and tight.  Our
      # > assumption of even edge weights ensures that all quantities
      # > computed are integers.  The dual adjustment decreases the
      # > dual objective (y, z)V by ƒδ where ƒ is the number of free
      # > vertices. (Gabow, 1985, p. 92)
      def dual_variable_adjustmeent
        fail 'not yet implemented'
      end

      # > The augment step enlarges the matching M by one edge to
      # > M⨁P. (Gabow, 1985, p. 92)
      def augment(m, wap)
        fail 'not yet implemented'
      end

    end
  end
end
