require_relative 'explainable'
require_relative 'path'
require 'set'

module GraphMatching

  # TODO: Stop subclassing `Set` and only use @ary, which is far more efficient.
  class Matching < Set

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

    def initialize(*args)
      @ary = [] # An optimized structure (see `.gabow`)
      super
    end

    def add(o)
      super(to_undirected_edge(o)) # TODO: Stop subclassing `Set` and only use @ary
      @ary[o[0]] = o[1]
      @ary[o[1]] = o[0]
    end

    def augment(augmenting_path)
      ap = Path.new(augmenting_path)
      augmenting_path_edges = ap.edges
      raise "invalid augmenting path: must have odd length" unless augmenting_path_edges.length.odd?
      augmenting_path_edges.each_with_index do |edge, ix|
        if ix.even?
          add(edge)
        else
          delete(edge)
        end
      end

      # Validating after every augmentation is wasteful and will
      # be removed when this library is more mature.
      validate
    end

    def delete(edge)
      delete_if { |e| array_match?(e, edge) } # TODO: Stop subclassing `Set` and only use @ary
      @ary[edge[0]] = nil
      @ary[edge[1]] = nil
    end

    def has_any_vertex?(*v)
      vertexes.any? { |vi| v.include?(vi) }
    end

    def has_edge?(e)
      !@ary[e[0]].nil? &&
        !@ary[e[1]].nil? &&
        @ary[e[0]] == e[1] &&
        @ary[e[1]] == e[0]
    end

    def has_vertex?(v)
      vertexes.include?(v)
    end

    # `match` returns the matched vertex (across the edge) or
    # nil if `v` is not matched
    def match(v)
      (edge_from(v).to_a - [v])[0]
    end

    def merge(enum)
      super(enum.map { |e| to_undirected_edge(e) })
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

    def to_s
      '[' + to_a.map(&:to_s).join(', ') + ']'
    end

    def unmatched_vertexes_in(set)
      set - vertexes
    end

    # `validate` is a simple sanity check.  If all is
    # well, it returns `self`.
    def validate
      v = vertexes
      if v.length != v.uniq.length
        raise "Invalid matching: A vertex appears more than once."
      end
      self
    end

    def vertexes
      @ary.compact
    end

    private

    # `array_match?` returns true if both arrays have the same
    # elements, irrespective of order.
    def array_match?(a, b)
      a.to_a.group_by { |i| i } == b.to_a.group_by { |i| i }
    end

    # `edge_from` returns the edge that contains `vertex`.  If no
    # edge contains `vertex`, returns empty array.  See also `#match`
    def edge_from(vertex)
      find { |edge| edge.to_a.include?(vertex) } || []
    end

    def to_undirected_edge(o)
      klass = RGL::Edge::UnDirectedEdge
      o.is_a?(klass) ? o : klass.new(*o.to_a)
    end

  end
end
