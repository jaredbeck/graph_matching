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

    def eq(other)
      unless obj == other
        fail "Expected #{other}, got #{obj}"
      end
    end

    def gte(other)
      unless obj >= other
        fail "Expected #{obj} to be >= #{other}"
      end
    end

    # rubocop:disable Style/PredicateName
    def is_a(klass)
      unless obj.is_a?(klass)
        fail TypeError, "Expected #{klass}, got #{obj.class}"
      end
    end
    # rubocop:enable Style/PredicateName

    def not_nil
      if obj.nil?
        fail 'Unexpected nil'
      end
    end
  end
end
