module GraphMatching

  class Visualize

    GRAPHVIZ_EDGE_DELIMITER = '--'

    attr_reader :graph

    def initialize(graph)
      @graph = graph
    end

    # `png` writes a ".dot" file and opens it with graphviz
    # TODO: do the same thing, but without the temporary ".dot" file
    # by opening a graphviz process and writing to its STDIN
    def png(base_filename)
      dir = '/tmp/graphviz'
      Dir.mkdir(dir) unless Dir.exists?(dir)
      abs_base_path = "#{dir}/#{base_filename}"
      File.open(abs_base_path + '.dot', 'w') { |file|
        file.write("strict graph G {\n")
        graph.each_edge { |u,v|
          file.write([u,v].join(GRAPHVIZ_EDGE_DELIMITER) + "\n")
        }
        file.write("}\n")
      }
      system "cat #{abs_base_path}.dot | dot -T png > #{abs_base_path}.png"
      system "open #{abs_base_path}.png"
    end

  end

end
