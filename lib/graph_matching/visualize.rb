# encoding: utf-8

require 'open3'

module GraphMatching

  class Visualize

    GRAPHVIZ_EDGE_DELIMITER = '--'
    TMP_DIR = '/tmp/graph_matching'
    USR_BIN_ENV = '/usr/bin/env'

    attr_reader :graph

    def initialize(graph)
      @graph = graph
    end

    # `dot` returns a string representing the graph, in .dot format.
    # http://www.graphviz.org/content/dot-language
    # TODO: Try using `rgl-0.4.0/lib/rgl/dot.rb` instead.
    def dot
      s = "strict graph G {\n"
      graph.each_edge { |u, v|
        e = [u, v].map { |x| safe_vertex(x) }
        s << e.join(GRAPHVIZ_EDGE_DELIMITER) + ";\n"
      }
      s << "}\n"
      s
    end

    # `png` writes a ".png" file with graphviz and opens it
    def png(base_filename)
      check_that_dot_is_installed
      mk_tmp_dir
      abs_path = "#{TMP_DIR}/#{base_filename}.png"
      write_png(abs_path)
      system "open #{abs_path}"
    end

  private

    def check_that_dot_is_installed
      unless dot_installed?
        $stderr.puts "The graphviz executable named dot is not installed"
        $stderr.puts "Please install graphviz"
        exit(1)
      end
    end

    def assert_usr_bin_env_exists
      unless File.exists?(USR_BIN_ENV)
        $stderr.puts "File not found: #{USR_BIN_ENV}"
        exit(1)
      end
    end

    # `dot_installed?` returns true if `dot` is installed, otherwise
    # false.  Note that `system` returns true if the command gives
    # zero exit status, false for non-zero exit status.
    def dot_installed?
      assert_usr_bin_env_exists
      system "#{USR_BIN_ENV} which dot > /dev/null"
    end

    def mk_tmp_dir
      Dir.mkdir(TMP_DIR) unless Dir.exists?(TMP_DIR)
    end

    def safe_vertex(v)
      if v.is_a?(Integer)
        v
      elsif v.respond_to?(:to_dot)
        v.to_dot
      else
        v.to_s.gsub(/[^a-zA-Z0-9]/, '')
      end
    end

    def write_png(abs_path)
      so, se, st = Open3.capture3("dot -T png > #{abs_path}", stdin_data: dot)
      if st.exitstatus != 0
        $stderr.puts "Failed to generate .png"
        $stderr.puts se
        exit(1)
      end
    end

  end

end
