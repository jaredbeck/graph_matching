require 'rgl/adjacency'
require 'rgl/connected_components'

module GraphMatching
  class Graph < RGL::AdjacencyGraph

    def connected?
      count = 0
      each_connected_component { |c| count += 1 }
      count == 1
    end

  end
end
