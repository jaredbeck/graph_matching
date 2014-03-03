require 'rgl/adjacency'
require 'rgl/connected_components'

module GraphMatching

  class DisconnectedGraphError < StandardError
  end

  class Graph < RGL::AdjacencyGraph
    include Explainable

    GRAPHVIZ_EDGE_DELIMITER = '--'

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

    def maximum_cardinality_matching
      return Matching.new if empty?
      raise DisconnectedGraphError unless connected?
      mcm_stage(Matching.new, vertices.first)
    end

    # `mcm_stage` - Given a matching `m` and an unmatched
    # vertex `u`, returns an augmented matching.
    def mcm_stage(m, u)
      s = LabelSet.new([u], 'S')
      t = LabelSet.new([], 'T')
      mark = LabelSet.new([], 'mark')
      predecessors = Hash.new
      aug_path = nil

      # If S has no unmarked vertex, stop; there is no M-augmenting
      # path from u.  Otherwise, select an unmarked v ∈ S.

      while v = (s - mark).to_a.sample
        log("v: #{v}")

        # To explore from v, successively consider each y ∈ N(v)
        # such that y ∉ T.
        (adjacent_vertices(v) - t.to_a).each do |y|
          log("y: #{y}")
          predecessors[y] = v

          # If y is unsaturated by M, then trace back from y (expanding
          # blossoms as needed) to report an M-augmenting u, y-path.
          if !m.has_edge?([v, y])
            log('backtrack')
            aug_path = backtrack_from(y, predecessors)
            break

          # If y ∈ S, then a blossom has been found.  Suspend the
          # exploration of v and contract the blossom, replacing its
          # vertices in S and T by a single new vertex in S.  Continue
          # the search from this vertex in the smaller graph.
          elsif s.include?(y)
            log('found blossom. contraction not yet implemented')

          # Otherwise, y is matched to some w by M.  Include y in T
          # (reached from v), and include w in S (reached from y).
          else
            w = m.match(y)
            t.add(y)
            s.add(w)
          end
        end

        break unless aug_path.nil?

        # After exploring all such neighbors of v, mark v and iterate.
        log('After exploring all such neighbors of v, mark v and iterate.')
        mark.add(v)
      end

      aug_path.nil? ? m.validate : mcm_stage(m.augment(aug_path), u)
    end

    # `print` writes a ".dot" file and opens it with graphviz
    # TODO: do the same thing, but without the temporary ".dot" file
    # by opening a graphviz process and writing to its STDIN
    def print(base_filename)
      dir = '/tmp/graphviz'
      Dir.mkdir(dir) unless Dir.exists?(dir)
      abs_base_path = "#{dir}/#{base_filename}"
      File.open(abs_base_path + '.dot', 'w') { |file|
        file.write("strict graph G {\n")
        each_edge { |u,v|
          file.write([u,v].join(GRAPHVIZ_EDGE_DELIMITER) + "\n")
        }
        file.write("}\n")
      }
      system "cat #{abs_base_path}.dot | dot -T png > #{abs_base_path}.png"
      system "open #{abs_base_path}.png"
    end

  end
end
