require_relative 'explainable'
require 'set'

module GraphMatching
  class Matching < Set
    include Explainable

    def augment(augmenting_path)
      log("augmenting the matching. path: #{augmenting_path.inspect}")

      raise "invalid path: must have length of at least two" unless augmenting_path.length >= 2
      augmenting_path_edges = []
      0.upto(augmenting_path.length - 2).each do |j|
        augmenting_path_edges << [augmenting_path[j], augmenting_path[j + 1]]
      end
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

    def edge_from(vertex)
      find { |edge| edge.include?(vertex) }
    end

    def has_edge?(edge)
      any? { |e| array_match?(e, edge) }
    end

    def has_vertex?(v)
      any? { |e| e.include?(v) }
    end

    def match(v)
      (edge_from(v) - [v])[0]
    end

    def unmatched_vertexes_in(set)
      set.select { |v| none? { |edge| edge.include?(v) } }
    end

    # `validate` is a simple sanity check.  If all is
    # well, it returns `self`.
    def validate
      flat = to_a.flatten
      if flat.length != flat.uniq.length
        $stderr.puts "Invalid matching: #{inspect}"
        raise "Invalid matching: A vertex appears more than once. "
      end
      self
    end

  private

    def array_match?(a, b)
      a.sort == b.sort
    end

  end
end
