module GraphMatching

  class GraphMatchingError < StandardError
  end

  class DisconnectedGraph < GraphMatchingError
  end

  class NotBipartite < GraphMatchingError
  end

end
