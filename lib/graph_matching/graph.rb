require 'rgl/adjacency'
require 'rgl/connected_components'

# TODO: autoload?
require_relative 'shrunken_blossom'

module GraphMatching

  class DisconnectedGraphError < StandardError
  end

  class Graph < RGL::AdjacencyGraph
    include Explainable

    def self.new_from_set_of_edges(edges)
      edges_flattened = edges.map { |e| e.to_a }.flatten
      self[*edges_flattened]
    end

    def backtrack_from(end_vertex, predecessors)
      # log("found augmenting path. backtracking ..")
      augmenting_path = [end_vertex]
      # log("predecessors: #{predecessors.inspect}")
      while predecessors.has_key?(augmenting_path.last)
        augmenting_path.push(predecessors[augmenting_path.last])
      end
      # log("augmenting path: #{augmenting_path.inspect}")
      augmenting_path
    end

    def connected?
      count = 0
      each_connected_component { |c| count += 1 }
      count == 1
    end

    # `maximal_matching` - Not to be confused with a *maximum* matching.
    # > A maximal matching is defined as a matching in which
    # > no edge in G can be added to the matching.
    # > (Kusner, Edmonds's Blossom Algorithm, p. 1)
    def maximal_matching
      m = Matching.new
      edges.each do |e|
        if m.unmatched_vertexes_in(Set.new(e.to_a)).length == 2
          m.add(e.to_a)
        end
      end
      m.validate
    end

    def maximum_cardinality_matching
      return Matching.new if empty?
      raise DisconnectedGraphError unless connected?
      m = maximal_matching
      u = first_unmatched_vertex(m)
      (u.nil? || m.empty?) ? m : mcm_stage(m, u)
    end

    # `mcm_stage` - Given a matching `m` and an unmatched
    # vertex `ri`, returns an augmented matching.
    def mcm_stage(m, ri)
      log('mcm_stage: matching: ' + m.inspect)
      fail 'TODO'
    end

    def print(base_filename)
      Visualize.new(self).png(base_filename)
    end

    def vertexes
      to_a
    end

    protected

    # `unmatched_adjacent_to` is poorly named.  It returns vertexes
    # across adjacent unmatched edges.  However, vertexes in the
    # returned array may be matched by non-adjacent edges.
    def unmatched_adjacent_to(vertex, matching)
      adjacent_vertices(vertex).reject { |a| matching.has_edge?([vertex, a]) }
    end

    private

    def first_unmatched_vertex(m)
      vertices.find { |v| !m.has_vertex?(v) }
    end

  end
end
