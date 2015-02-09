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

    # van Rantwijk's implementation expects consecutive positive
    # integers starting with zero.
    #
    # > Vertices are identified by consecutive, non-negative integers.
    # > (van Rantwijk, mwmatching.py, line 98)
    #
    # I believe this assertion can be applied in the other
    # algorithms as well, but I'll have to check.  Also,
    # I suspect I'll need to change IntegerVertexes to start
    # at zero.
    #
    def are_natural_numbers
      expected = 0
      obj.each do |v|
        raise InvalidVertexNumbering unless v == expected
        expected += 1
      end
    end

    def eq(other)
      unless obj == other
        raise "Expected #{other}, got #{obj}"
      end
    end

    def gte(other)
      unless obj >= other
        raise "Expected #{obj} to be >= #{other}"
      end
    end

    def is_a(klass)
      unless obj.is_a?(klass)
        raise TypeError, "Expected #{klass}, got #{obj.class}"
      end
    end

    def not_nil
      if obj.nil?
        raise "Unexpected nil"
      end
    end

  end
end
