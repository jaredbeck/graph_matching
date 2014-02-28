require 'set'

module GraphMatching
  class Matching < Set

    def assert_valid
      flat = to_a.flatten
      if flat.length != flat.uniq.length
        $stderr.puts "Invalid matching: #{inspect}"
        raise "Invalid matching: A vertex appears more than once. "
      end
    end

    def augment(augmenting_path)
      raise "invalid path: must have length of at least two" unless augmenting_path.length >= 2
      augmenting_path_edges = []
      0.upto(augmenting_path.length - 2).each do |j|
        augmenting_path_edges << [augmenting_path[j], augmenting_path[j + 1]]
      end
      raise "invalid augmenting path: must have odd length" unless augmenting_path_edges.length.odd?
      puts "augmenting the matching"
      augmenting_path_edges.each_with_index do |edge, ix|
        if ix.even?
          add(edge)
        else
          delete_if { |e| array_match?(e, edge) }
        end
      end
    end

  private

    def array_match?(a, b)
      a.sort == b.sort
    end

  end
end
