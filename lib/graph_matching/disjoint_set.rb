# - http://en.wikipedia.org/wiki/Disjoint-set_data_structure
# - http://www.markhneedham.com/blog/2012/12/23/kruskals-algorithm-using-union-find-in-ruby/
# - https://github.com/optiminimalist/Union-Find-Ruby

module GraphMatching
  class DisjointSet
    def initialize(n)
      @ids = (0..n-1).to_a
    end

    def connected?(id1, id2)
      @ids[id1] == @ids[id2]
    end

    def union(id1, id2)
      id_1, id_2 = @ids[id1], @ids[id2]
      @ids.map! { |i| (i == id_1) ? id_2 : i }
    end
  end
end
