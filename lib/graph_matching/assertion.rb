# frozen_string_literal: true

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
        raise "Expected #{other}, got #{obj}"
      end
    end

    def gte(other)
      unless obj >= other
        raise "Expected #{obj} to be >= #{other}"
      end
    end

    # rubocop:disable Naming/PredicateName
    def is_a(klass)
      unless obj.is_a?(klass)
        raise TypeError, "Expected #{klass}, got #{obj.class}"
      end
    end
    # rubocop:enable Naming/PredicateName

    def not_nil
      if obj.nil?
        raise 'Unexpected nil'
      end
    end
  end
end
