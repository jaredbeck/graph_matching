# encoding: utf-8

module GraphMatching
  # > In graph theory, a path in a graph is a finite or infinite
  # > sequence of edges which connect a sequence of vertices
  # > which, by most definitions, are all distinct from one
  # > another.
  # > https://en.wikipedia.org/wiki/Path_%28graph_theory%29
  class Path
    attr_reader :vertexes

    def initialize(vertexes)
      unless vertexes.length >= 2
        fail ArgumentError, 'Invalid path: Needs at least two vertexes'
      end
      @vertexes = vertexes.to_a
    end

    def edges
      e = []
      0.upto(vertexes.length - 2).each do |j|
        e << [vertexes[j], vertexes[j + 1]]
      end
      e
    end

    def length
      vertexes.length
    end
  end
end
