require_relative 'explainable'
require_relative 'graph'
require_relative 'matching'
require 'rgl/traversal'

module GraphMatching

  class NotBipartiteError < StandardError
  end

  # A bipartite graph (or bigraph) is a graph whose vertices can
  # be divided into two disjoint sets U and V such that every
  # edge connects a vertex in U to one in V.
  class BipartiteGraph < Graph
    include Explainable

    # `maximum_cardinality_matching` returns a `Set` of arrays,
    # each representing an edge in the matching.  The augmenting
    # path algorithm is used.
    #
    def maximum_cardinality_matching
      m = Matching.new
      u, v = partition
      debug("partitions: #{u.inspect} #{v.inspect}")

      # For each stage (until no augmenting path is found)
      while true do
        debug("\nbegin stage: #{m.inspect}")

        # 0. Clear all labels and marks
        label_t = Set.new
        label_r = Set.new
        mark_r = Set.new
        predecessors = Hash.new
        augmenting_path = nil

        # 1. Label unmatched vertexes in U with label R
        # These R-vertexes are candidates for the start of an augmenting path.
        u.each { |ui| label_r.add(ui) if m.none? { |mi| mi.include?(ui) } }
        debug("label r: #{label_r.inspect}")

        # 2. While there are unmarked R-vertexes
        unmarked_r = label_r
        while augmenting_path.nil? && !unmarked_r.empty?
          start = unmarked_r.to_a.sample
          mark_r.add(start)
          debug("r-mark: #{start}")

          # 3. Follow the unmatched edges (if any) to vertexes in V
          each_adjacent(start) do |vi|
            debug("  adjacent: #{vi}")
            if !matched?([start, vi], m)

              # 4. Does the vertex in V have label T?
              if label_t.include?(vi)
                #   A. If yes, do what?
                raise "  Found a T-vertex.  What next?"
              else
                #   B. If no, label with T.  Now, is it matched?
                debug("  t-label: #{vi}")
                label_t.add(vi)
                predecessors[vi] = start

                vi_edges = adjacent_vertices(vi).reject { |vie| vie == start }
                if vi_edges.empty?
                  debug("  vi_edges is empty, so we found an augmenting path?")
                  augmenting_path = [vi, start]
                  debug("  augmenting path: #{augmenting_path.inspect}")
                else

                  # is there a matched edge?
                  matched_edge_found = false
                  vi_edges.each do |ui|
                    if matched?([ui, vi], m)
                      # follow that edge to a vertex in U and label the U-vertex with R
                      debug("    r-label: #{ui}")
                      label_r.add(ui)
                      predecessors[ui] = vi
                      matched_edge_found = true
                    end
                  end

                  # If any matched edges were found, return to step 2.
                  unless matched_edge_found
                    # No matched edges were found, therefore we have
                    # found an augmenting path.  Backtrack to construct
                    # the augmenting path, augment the matching, and
                    # return to step 1.
                    augmenting_path = backtrack_from(vi, predecessors)
                  end
                end

                unless augmenting_path.nil?
                  break
                end

              end
            end
          end

          unmarked_r = label_r - mark_r
        end

        if augmenting_path.nil?
          debug("Unable to find an augmenting path.  We're done!")
          break
        else
          m.augment(augmenting_path)
        end
      end

      m.assert_valid

      m
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

    def assert_disjoint(u, v)
      raise "Expected sets to be disjoint" unless u.disjoint?(v)
    end

    def backtrack_from(end_vertex, predecessors)
      debug("    found augmenting path. backtracking ..")
      augmenting_path = [end_vertex]
      debug("    predecessors: #{predecessors.inspect}")
      while predecessors.has_key?(augmenting_path.last)
        augmenting_path.push(predecessors[augmenting_path.last])
      end
      debug("    augmenting path: #{augmenting_path.inspect}")
      augmenting_path
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

    def matched?(edge, matching)
      matching.any? { |e| e.include?(edge[0]) && e.include?(edge[1]) }
    end

  end
end
