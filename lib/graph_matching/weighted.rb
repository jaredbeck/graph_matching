module GraphMatching

  # The `Weighted` module is mixed into undirected graphs to
  # support edge weights.  Directed graphs are not supported.
  #
  # Data Structure
  # --------------
  #
  # If directed graphs were supported, a 2D array
  # would be an obvious choice of data structure.  However, because
  # directed graphs are not supported, one might argue that
  # using a 2D array wastes memory; a symmetrical matrix can
  # be stored in a 1D array to save memory. (http://bit.ly/1DMfLM3)
  # However, translating the 2D coordinates into a 1D index
  # marginally increases the cost of access, and this is a read-heavy
  # structure, so maybe the extra memory is an acceptable trade-off.
  #
  module Weighted
    def initialize
      super
      @weight = Array.new(num_vertices) { |_| Array.new(num_vertices) }
    end

    def w(edge)
      i, j = edge
      @weight[i - 1][j - 1]
    end

    def set_w(edge, weight)
      raise TypeError unless weight.is_a?(Integer)
      i, j = edge[0] - 1, edge[1] - 1
      @weight[i][j] = weight
      @weight[j][i] = weight
    end
  end
end
