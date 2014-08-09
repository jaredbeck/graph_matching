require_relative 'explainable'
require_relative 'path'
require 'set'

module GraphMatching
  class Matching < Set
    include Explainable

    def augment(augmenting_path)
      log("augmenting the matching. path: #{augmenting_path.inspect}")
      ap = Path.new(augmenting_path)
      augmenting_path_edges = ap.edges
      raise "invalid augmenting path: must have odd length" unless augmenting_path_edges.length.odd?
      augmenting_path_edges.each_with_index do |edge, ix|
        if ix.even?
          add(edge)
        else
          delete_if { |e| array_match?(e, edge) }
        end
      end

      # Validating after every augmentation is wasteful and will
      # be removed when this library is more mature.
      validate
    end

    def has_edge?(edge)
      any? { |e| array_match?(e, edge) }
    end

    def has_vertex?(v)
      any? { |e| e.include?(v) }
    end

    # `match` returns the matched vertex (across the edge) or
    # nil if `v` is not matched
    def match(v)
      (edge_from(v) - [v])[0]
    end

    def unmatched_vertexes_in(set)
      set - vertexes
    end

    # `validate` is a simple sanity check.  If all is
    # well, it returns `self`.
    def validate
      v = vertexes
      if v.length != v.uniq.length
        log("Invalid matching: #{inspect}")
        raise "Invalid matching: A vertex appears more than once."
      end
      self
    end

    def vertexes
      to_a.flatten
    end

    private

    # `array_match?` returns true if both arrays have the same
    # elements, irrespective of order.
    def array_match?(a, b)
      a.group_by { |i| i } == b.group_by { |i| i }
    end

    # `edge_from` returns the edge that contains `vertex`.  If no
    # edge contains `vertex`, returns empty array.  See also `#match`
    def edge_from(vertex)
      find { |edge| edge.include?(vertex) } || []
    end

  end
end
