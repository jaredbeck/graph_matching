# encoding: utf-8

module GraphMatching

  # Provides expressive methods for common runtime assertions, e.g.
  #
  #   assert(banana).is_a(Fruit)
  #
  class Assertion

    attr_reader :obj

    def initialize(obj)
      @obj = obj
    end

    def is_a(klass)
      unless obj.is_a?(klass)
        raise TypeError, "Expected #{klass}, got #{obj.class}"
      end
    end

  end
end
