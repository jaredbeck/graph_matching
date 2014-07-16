require_relative 'explainable'
require 'set'

module GraphMatching
  class LabelSet < Set
    include Explainable

    attr_reader :label, :v

    def initialize(enum, label)
      @label = label
      @v = {}
      super(enum)
    end

    def add(o, v = nil)
      log("Label #{o} with (#{label}, #{v})")
      super(o)
      @v[o] = v
    end

    def get(o)
      @v.fetch(o)
    end

  end
end
