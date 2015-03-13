# encoding: utf-8

require 'open3'
require 'rgl/rdot'

module GraphMatching
  # Renders `GraphMatching::Graph` objects using `graphviz`.
  class Visualize
    TMP_DIR = '/tmp/graph_matching'
    USR_BIN_ENV = '/usr/bin/env'

    attr_reader :graph

    def initialize(graph)
      @graph = graph
    end

    # `dot` returns a string representing the graph, in .dot format.
    # http://www.graphviz.org/content/dot-language
    def dot
      RGL::DOT::Graph.new('elements' => dot_edges).to_s
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
      return if dot_installed?
      $stderr.puts "Executable not found: dot"
      $stderr.puts "Please install graphviz"
      exit(1)
    end

    def dot_edge(u, v, label)
      RGL::DOT::Edge.new(
        { 'from' => u, 'to' => v, 'label' => label },
        ['label']
      )
    end

    def dot_edges
      graph.edges.map { |e| dot_edge(e.source, e.target, dot_edge_label(e)) }
    end

    def dot_edge_label(edge)
      graph.is_a?(GraphMatching::Graph::Weighted) ? graph.w([*edge]) : nil
    end

    def assert_usr_bin_env_exists
      return if File.exist?(USR_BIN_ENV)
      $stderr.puts "File not found: #{USR_BIN_ENV}"
      exit(1)
    end

    # `dot_installed?` returns true if `dot` is installed, otherwise
    # false.  Note that `system` returns true if the command gives
    # zero exit status, false for non-zero exit status.
    def dot_installed?
      assert_usr_bin_env_exists
      system "#{USR_BIN_ENV} which dot > /dev/null"
    end

    def mk_tmp_dir
      Dir.mkdir(TMP_DIR) unless Dir.exist?(TMP_DIR)
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
      _so, se, st = Open3.capture3("dot -T png > #{abs_path}", stdin_data: dot)
      return if st.success?
      $stderr.puts "Failed to generate .png"
      $stderr.puts se
      exit(1)
    end
  end
end
