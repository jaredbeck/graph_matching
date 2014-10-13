require 'rgl/adjacency'
require 'rgl/connected_components'
require_relative 'ordered_set'

module GraphMatching

  class DisconnectedGraphError < StandardError
  end

  # An LFlag represents a flag on an edge during Gabow's `l` function.
  class LFlag
    attr_reader :edge
    def initialize(edge)
      @edge = edge
    end
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

    # `bfs` - Breadth-First Search. Takes a starting point, `from`,
    # and a block to which visited nodes will be yielded.
    def bfs(from)
      visited = Set.new
      q = OrderedSet[from]
      until q.empty?
        v = q.deq
        yield v
        visited.add(v)
        discovered = Set.new(adjacent_vertices(v)) - visited
        q.push(*discovered)
      end
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
      (u.nil? || m.empty?) ? m : e
    end

    # `e` constructs a maximum matching on a graph.  It starts a
    # search for an augmenting path to each unmatched vertex u.
    # It scans edges of the graph, deciding to assign new labels
    # or to augment the matching.
    def e
      first = []
      label = []
      mate = []

      # E0. [Initialize.] Read the graph into adjacency lists,
      # numbering the vertices 1 to V and the edges V + 1 to
      # V + 2W. Create a dummy vertex 0 For 0 <= i <= V, set
      # LABEL(u) <- -1, MATE(i) <- 0 (all vertices are nonouter
      # and unmatched) Set u <- 0

      label.fill(-1, 0, size + 1)
      mate.fill(0, 0, size + 1)
      u = 0

      # El. [Find unmatched vertex ] Set u = u + 1. If u > V,
      # halt; MATE contains a maximum matching Otherwise, if vertex
      # u is matched, repeat step E1 Otherwise (u is unmatched, so
      # assign a start label and begin a new search)
      # set LABEL(u) = FIRST(u) = 0

      e1_loop = true
      guard = 0
      while e1_loop && guard < 1000 do
        guard += 1

        u += 1
        log("E1 u: #{u}")
        break if u > size
        if mate[u] != 0
          next # repeat E1
        else
          log("E1 label #{u} with 0 (indicates 'start' label?)")
          label[u] = first[u] = 0
        end

      # E2 [Choose an edge ] Choose an edge xy, where x is an outer
      # vertex. (An edge vw may be chosen twice in a search--once
      # with x = v, and once with x = w.) If no such edge exists,
      # go to E7. (Edges xy can be chosen in an arbitrary order. A
      # possible choice method is "breadth-first": an outer vertex
      # x = x1 is chosen, and edges (x1,y) are chosen in succeeding
      # executions of E2, when all such edges have been chosen, the
      # vertex x2 that was labeled immediately after x1 is chosen,
      # and the process is repeated for x = x2. This breadth-first
      # method requires that Algorithm E maintain a list of outer
      # vertices, x1, x2, ...)

        searching = true
        visited_nodes = Set.new
        visited_edges = Set.new
        q = OrderedSet[u]
        while searching && !q.empty?
          log('')
          log("E2 q: #{q.to_a}")
          x = q.deq
          visited_nodes.add(x)
          log("E2 x: #{x}")
          adjacent_edges = adjacent_vertices(x).sort.map { |j| DirectedEdge.new(x, j) }
          discovered_edges = Set.new(adjacent_edges) - visited_edges
          log("E2 discovered_edges: #{discovered_edges.to_a.map { |edge| edge.to_a }}")

          discovered_edges.each do |edge|
            visited_edges.add(edge)
            y = edge.target
            log("E2 y: #{y}")
            log("E2 labels: #{label}")
            log("E2 mate: #{mate}")

      # E3. [Augment the matching.] If y is unmatched and y != u,
      # set MATE(y) = x, call R(x, y): then go to E7 (R
      # completes the augment along path (y)*P(x))

            if mate[y] == 0 && y != u
              log('E3')
              mate[y] = x
              r(x, y, mate)
              searching = false # go to E7
              break

      # E4. [Assign edge labels.] If y is outer, call L, then go to
      # E2 (L assigns edge label n(xy) to nonouter vertices in P(x)
      # and P(y))

            elsif label[y] >= 0 # outer
              log("E4 first: #{first}")
              l(x, y, first, label, mate)

      # E5. [Assign a vertex label.] Set v <- MATE(y). If v is
      # nonouter, set LABEL(v) <- x, FIRST(v) <- y, and go to E2
      #
      # E6. [Get next edge.] Go to E2 (y is nonouter and MATE(y) is
      # outer, so edge xy adds nothing).

            else
              v = mate[y]
              log("E5 v: #{v} labels: #{label}")
              if label[v] == -1 # nonouter
                log("E5 label #{v} with #{x}")
                label[v] = x
                first[v] = y
              end
              unless visited_nodes.include?(v)
                log("E6 enqueue #{v}")
                q.enq(v)
              end
            end

          end
        end

      #
      # E7. [Stop the search] Set LABEL(O) <- -1. For all outer
      # vertices i set LABEL(i) <- LABEL(MATE(i)) <- -1 Then go
      # to E1 (now all vertexes are nonouter for the next search).
      #

        log('E7')
        label[0] = -1
        label.each_with_index do |obj, ix|
          if ix > 0 && outer?(obj, label)
            label[ix] = label[mate[ix]] = -1
          end
        end

        log('')
      end # while e0_loop
    end

    # L assigns the edge label n(xy) to nonouter vertices. Edge xy
    # joins outer vertices x, y. L sets join to the first nonouter
    # vertex in both P(x) and P(y). Then it labels all nonouter
    # vertices preceding join in P(x) or P(y).
    def l(x, y, first, label, mate)

      # L0. [Initialize.] Set r <- FIRST(x), s <= FIRST(y).
      # If r = s, return (no vertices can be labeled).
      # Otherwise flag r and s. (Steps L1-L2 find join by advancing
      # alternately along paths P(x) and P(y). Flags are assigned
      # to nonouter vertices r in these paths. This is done by
      # setting LABEL(r) to a negative edge number, LABEL(r) <- -n(xy).
      # This way, each invocation of L uses a distinct flag value.)

      r = first[x]
      s = first[y]
      log("L0 x: #{x} r: #{r}")
      log("L0 y: #{y} s: #{s}")

      if r == s
        return # no vertices can be labeled
      else
        log "L0 label (flag) #{r} with n(#{x}, #{y})"
        label[r] = LFlag.new(n(x, y))
      end

      # L1. [Switch paths ] If s != 0, interchange r and s, r <-> s
      # (r is a flagged nonouter vertex, alternately in P(x) and P(y)).

      log "L1"
      finding_join = true
      while finding_join
        if s != 0
          temp = r
          r = s
          s = temp
        end

      # L2. [Next nonouter vertex.] Set r <- FIRST(LABEL(MATE(r)))
      # (r is set to the next nonouter vertex in P(x) or P(y)). If
      # r is not flagged, flag r and go to L1 Otherwise set
      # join <- r and go to L3.

        log "L2 r: #{r} s: #{s}"
        r = first[label[mate[r]]]
        log "L2 r: #{r}"
        if label[r].is_a?(LFlag)
          join = r
          finding_join = false
        else
          label[r] = LFlag.new(n(x, y))
        end
      end

      # L3. [Label vertices in P(x), P(y).] (All nonouter vertexes
      # between x and join, or y and join, will be assigned edge
      # labels. See Figure 4(a).) Set v <- FIRST(x) and do L4. Then
      # set v <- FIRST(y) and do L4. Then go to L5.

      [first[x], first[y]].each do |v|
        log "L3 join: #{join} v: #{v}"

      # L4 [Label v] If v != join, set LABEL(v) <- n(xy), FIRST(v) <- join,
      # v <- FIRST(LABEL(MATE(v))) and repeat step L4
      # Otherwise continue as specified in L3.

          until v == join
            label[v] = n(x, y)
            first[v] = join
            v = first[label[mate[v]]]
            log("L4 v: #{v}")
          end
      end

      # L5 [Update FIRST] For each outer vertex i, if FIRST(i) is
      # outer, set FIRST(i) <- join. (Join is now the first nonouter
      # vertex in P(i))

      log 'L5'
      outers = label.select { |l| outer?(l, label) }
      outers.each do |i|
        if outers.include?(first[i])
          first[i] = join
        end
      end

      # L6. [Done] Return

      log "L6 label: #{label}"
    end

    # Gabow (1976) describes a function `n` which returns the number
    # of the edge from `x` to `y`.  Because we are using RGL, and
    # not implementing our own adjacency lists, we can simply return
    # an RGL::UnDirectedEdge.
    def n(x, y)
      UnDirectedEdge.new(x, y)
    end

    def nonouter?(node, labels)
      l = labels[node]
      l.is_a?(Integer) && l == -1
    end

    def outer?(node, labels)
      !nonouter?(node, labels)
    end

    # R (v, w) rematches edges in the augmenting path. Vertex v is
    # outer. Part of path (w) * P(v) is in the augmenting path. It
    # gets rematehed by R(v, w) (Although R sets MATE(v) +- w, it
    # does not set MATE(w) <- v. This is done in step E3 or another
    # call to R.) R is a recursive routine.
    def r(v, w, mate)
      log("R0 (v, w, mate): #{v}, #{w}, #{mate}")

      # R1. [Match v to w ] Set t <- MATE(v), MATE(v) <- w.
      # If MATE(t) != v, return (the path is completely re-matched)

      t = mate[v]
      mate[v] = w
      log("R0 augmented: #{mate}")
      return if mate[t] != v

      # R2. [Rematch a path.] If v has a vertex label, set
      # MATE(t) ~-- LABEL(v), call R(LABEL(v), t) recursivcly, and
      # then return.

      fail 'TODO'

      # R3. [Rematch two paths.] (Vertex v has an edge label ) Set
      # x, y to vertices so LABEL(v) = n(xy), call R(x, y)
      # recurslvely, call R(y, x) recurslvely, and then return.
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
