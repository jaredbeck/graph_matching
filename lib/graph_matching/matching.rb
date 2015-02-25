# encoding: utf-8

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
        if !n1.nil? && n1 != 0
          n2 = mate[n1]
          if n2 == ix
            m.add([n1, n2])
          end
        end
      end
      m
    end

    # Van Rantwijk's matching is constructed from two arrays,
    # `mate` and `endpoint`.
    #
    # - `endpoint` is an array where each edge is represented by
    #   two consecutive elements, which are vertex numbers.
    # - `mate` is an array whose indexes are vertex numbers, and
    #   whose values are `endpoint` indexes, or `nil` if the vertex
    #   is single (unmatched).
    #
    # A matched vertex `v`'s partner is `endpoint[mate[v]]`.
    #
    def self.from_endpoints(endpoint, mate)
      m = Matching.new
      mate.each do |p|
        m.add([endpoint[p], endpoint[p ^ 1]]) unless p.nil?
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

    # `edges` returns an array of undirected edges, represented as
    # two-element arrays.
    def edges
      undirected_edges.map(&:to_a)
    end

    def empty?
      @ary.all?(&:nil?)
    end

    def has_edge?(e)
      i, j = e
      !@ary[i].nil? && @ary[i] == j && @ary[j] == i
    end

    def has_vertex?(v)
      @ary.include?(v)
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

    # Given a `Weighted` graph `g`, returns the sum of edge weights.
    def weight(g)
      edges.map { |e| g.w(e) }.reduce(0, :+)
    end

    def undirected_edges
      @ary.each_with_index.inject(Set.new) { |set, (el, ix)|
        el.nil? ? set : set.add(RGL::Edge::UnDirectedEdge.new(el, ix))
      }
    end

    def vertexes
      @ary.compact
    end

  end
end
