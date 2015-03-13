# encoding: utf-8

module GraphMatching
  class GraphMatchingError < StandardError
  end

  # no-doc
  class InvalidVertexNumbering < GraphMatchingError
    def initialize(msg = nil)
      msg ||= <<-EOS
Expected vertexes to be consecutive positive integers \
starting with zero
      EOS
      super(msg)
    end
  end

  class DisconnectedGraph < GraphMatchingError
  end

  class NotBipartite < GraphMatchingError
  end
end
