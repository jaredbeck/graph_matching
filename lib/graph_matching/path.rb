module GraphMatching
  class Path

    attr_reader :vertexes

    def initialize(vertexes)
      unless vertexes.length >= 2
        raise ArgumentError, 'Invalid path: Needs at least two vertexes'
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
