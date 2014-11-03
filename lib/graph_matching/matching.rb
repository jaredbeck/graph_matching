require_relative 'path'

module GraphMatching

  class Matching

    # Gabow (1976) uses a simple array to store his matching.  It
    # has one element for each vertex in the graph.  The value of
    # each element is either the number of another vertex (Gabow
    # uses sequential integers for vertex numbering) or a zero if
    # unmatched.  So, `.gabow` returns a `Matching` initialized
    # from such an array.
    def self.gabow(mate)
      m = new
      mate.each_with_index do |n1, ix|
        n2 = mate[n1]
        if n1 != 0 && n2 == ix
          m.add([n1, n2])
        end
      end
      m
    end

    def self.[](*edges)
      new.tap { |m| edges.each { |e| m.add(e) } }
    end

    def initialize
      @ary = []
    end

    def [](i)
      @ary[i]
    end

    def add(e)
      i, j = e
      @ary[i] = j
      @ary[j] = i
    end

    def delete(e)
      i, j = e
      @ary[i] = nil
      @ary[j] = nil
    end

    def empty?
      @ary.all?(&:nil?)
    end

    # `first` returns the first edge
    def first
      j = @ary.find { |e| !e.nil? }
      [@ary[j], j]
    end

    def has_any_vertex?(*v)
      vertexes.any? { |vi| v.include?(vi) }
    end

    def has_edge?(e)
      i, j = e
      !@ary[i].nil? && @ary[i] == j && @ary[j] == i
    end

    def has_vertex?(v)
      @ary.include?(v)
    end

    def inspect
      to_s
    end

    def replace(old:, new:)
      delete old
      add new
    end

    def replace_if_matched(match:, replacement:)
      replace(old: match, new: replacement) if has_edge?(match)
    end

    # `size` returns number of edges
    def size
      @ary.compact.size / 2
    end

    def to_a
      result = []
      skip = []
      @ary.each_with_index { |e, i|
        unless e.nil? || skip.include?(i)
          result << [i, e]
          skip << e
        end
      }
      result
    end

    def to_s
      '[' + to_a.map(&:to_s).join(', ') + ']'
    end

    def unmatched_vertexes_in(set)
      set - vertexes
    end

    def vertexes
      @ary.compact
    end

    private

    def to_undirected_edge(o)
      klass = RGL::Edge::UnDirectedEdge
      o.is_a?(klass) ? o : klass.new(*o.to_a)
    end

  end
end
