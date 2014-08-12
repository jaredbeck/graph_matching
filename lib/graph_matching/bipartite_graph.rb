require_relative 'explainable'
require_relative 'graph'
require_relative 'label_set'
require_relative 'matching'
require 'rgl/traversal'

module GraphMatching

  class NotBipartiteError < StandardError
  end

  # A bipartite graph (or bigraph) is a graph whose vertices can
  # be divided into two disjoint sets U and V such that every
  # edge connects a vertex in U to one in V.
  class BipartiteGraph < Graph

    # `maximum_cardinality_matching` returns a `Set` of arrays,
    # each representing an edge in the matching.  The augmenting
    # path algorithm is used.
    #
    def maximum_cardinality_matching
      u, v = partition
      log("partitions: #{u.inspect} #{v.inspect}")
      mcm_stage(Matching.new, u)
    end

    # Begin each stage (until no augmenting path is found)
    # by clearing all labels and marks
    def mcm_stage(m, u)
      log("\nbegin stage: #{m.inspect}")
      t = LabelSet.new([], 'T')
      marked = LabelSet.new([], 'mark')
      predecessors = Hash.new
      aug_path = nil

      # Label unmatched vertexes in U with label R.  These R-vertexes
      # are candidates for the start of an augmenting path.
      unmarked = r = LabelSet.new(m.unmatched_vertexes_in(u), 'R')
      log("label R: #{r.inspect}")

      # While there are unmarked R-vertexes
      while aug_path.nil? && start = unmarked.to_a.sample
        marked.add(start)

        # Follow the unmatched edges (if any) to vertexes in V
        # ignoring any V-vertexes already labeled T
        unmatched_unlabled_adjacent_to(start, m, t).each do |vi|
          t.add(vi)
          predecessors[vi] = start

          adj_u = vertices_adjacent_to(vi, except: [start])
          if adj_u.empty?
            log("Vertex #{vi} has no adjacent vertexes, so we found an augmenting path")
            aug_path = [vi, start]
          else

            # If there are matched edges, follow each to a vertex
            # in U and label the U-vertex with R.  Otherwise,
            # backtrack to construct an augmenting path.
            adj_u_in_m = matched_adjacent_to(vi, adj_u, m).each do |ui|
              r.add(ui)
              predecessors[ui] = vi
            end

            if adj_u_in_m.empty?
              aug_path = backtrack_from(vi, predecessors)
            end
          end

          break unless aug_path.nil?
        end

        unmarked = r - marked
      end

      aug_path.nil? ? m.validate : mcm_stage(m.augment(aug_path), u)
    end

    # `partition` either returns two disjoint (complementary)
    # proper subsets of vertexes or raises a NotBipartiteError
    def partition
      u = Set.new
      v = Set.new
      return [u,v] if empty?
      raise NotBipartiteError unless connected?
      i = RGL::BFSIterator.new(self)
      i.set_examine_edge_event_handler do |from, to|
        examine_edge_for_partition(from, to, u, v)
      end
      i.set_to_end # does the search
      assert_disjoint(u, v) # sanity check
      [u, v]
    end

  private

    def add_to_set(set, vertex:, fail_if_in:)
      raise NotBipartiteError if fail_if_in.include?(vertex)
      set.add(vertex)
    end

    def matched_adjacent_to(vertex, adjacent_vertexes, matching)
      adjacent_vertexes.select { |x| matching.has_edge?([x, vertex]) }
    end

    def unmatched_unlabled_adjacent_to(vertex, matching, labels)
      unmatched_adjacent_to(vertex, matching).reject { |v| labels.include?(v) }
    end

    def assert_disjoint(u, v)
      raise "Expected sets to be disjoint" unless u.disjoint?(v)
    end

    def examine_edge_for_partition(from, to, u, v)
      if u.include?(from)
        add_to_set(v, vertex: to, fail_if_in: u)
      elsif v.include?(from)
        add_to_set(u, vertex: to, fail_if_in: v)
      else
        u.add(from)
        v.add(to)
      end
    end

    def vertices_adjacent_to(vertex, except: [])
      adjacent_vertices(vertex) - except
    end

  end
end
