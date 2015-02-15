# encoding: utf-8

module GraphMatching
  module Graph

    # The `Weighted` module is mixed into undirected graphs to
    # support edge weights.  Directed graphs are not supported.
    #
    # Data Structure
    # --------------
    #
    # Weights are stored in a 2D array.  The weight of an edge i,j
    # is stored twice, at `[i][j]` and `[j][i]`.
    #
    # Storing the weight twice wastes memory.  A symmetrical matrix
    # can be stored in a 1D array (http://bit.ly/1DMfLM3)
    # However, translating the 2D coordinates into a 1D index
    # marginally increases the cost of access, and this is a read-heavy
    # structure, so maybe the extra memory is an acceptable trade-off.
    # It's also conceptually simpler, for what that's worth.
    #
    # If directed graphs were supported (they are not) this 2D array
    # would be an obvious choice.
    #
    # Algorithms which operate on weighted graphs are tightly
    # coupled to this data structure due to optimizations.
    #
    module Weighted

      def self.included(base)
        base.extend ClassMethods
        base.class_eval do
          attr_accessor :weight
        end
      end

      module ClassMethods

        # `.[]` is the recommended, convenient constructor for
        # weighted graphs.  Each argument should be an array with
        # three integers; the first two represent the edge, the
        # third, the weight.
        def [](*args)
          assert_weighted_edges(args)
          weightless_edges = args.map { |e| e.slice(0..1) }
          g = super(*weightless_edges.flatten)
          g.init_weights
          args.each do |edge|
            i, j, weight = edge[0] - 1, edge[1] - 1, edge[2]
            g.weight[i][j] = weight
            g.weight[j][i] = weight
          end
          g
        end

        # `assert_weighted_edges` asserts that `ary` is an array
        # whose elements are all arrays of exactly three elements.
        # (The first two represent the edge, the third, the weight)
        def assert_weighted_edges(ary)
          unless ary.is_a?(Array) && ary.all?(&method(:weighted_edge?))
            raise 'Invalid array of weighted edges'
          end
        end

        # `weighted_edge?` returns true if `e` is an array whose
        # first two elements are integers, and whose third element
        # is a real number.
        def weighted_edge?(e)
          e.is_a?(Array) &&
            e.length == 3 &&
            e[0, 2].all? { |i| i.is_a?(Integer) } &&
            e[2].is_a?(Integer) || e[2].is_a?(Float)
        end
      end

      def init_weights
        @weight = Array.new(num_vertices) { |_| Array.new(num_vertices) }
      end

      def max_w
        edges.map { |edge| w(edge.to_a) }.max
      end

      # Returns the weight of an edge.  Accessing `#weight` is much
      # faster, so this method should only be used where
      # clarity outweighs performance.
      def w(edge)
        i, j = edge
        raise ArgumentError, "Invalid edge: #{edge}" if i.nil? || j.nil?
        raise "Edge not found: #{edge}" unless has_edge?(*edge)
        init_weights if @weight.nil?
        @weight[i - 1][j - 1]
      end

      # `set_w` sets a single weight.  It not efficient, and is
      # only provided for situations where constructing the entire
      # graph with `.[]` is not convenient.
      def set_w(edge, weight)
        raise ArgumentError, "Invalid edge: #{edge}" if edge[0].nil? || edge[1].nil?
        raise TypeError unless weight.is_a?(Integer)
        init_weights if @weight.nil?
        i, j = edge[0] - 1, edge[1] - 1
        raise "Edge not found: #{edge}" unless has_edge?(*edge)
        @weight[i] ||= []
        @weight[j] ||= []
        @weight[i][j] = weight
        @weight[j][i] = weight
      end

    end
  end

end
