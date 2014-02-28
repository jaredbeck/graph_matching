require_relative 'explainable'
require 'set'

module GraphMatching
  class LabelSet < Set
    include Explainable

    attr_reader :label

    def initialize(enum, label)
      @label = label
      super(enum)
    end

    def add(o)
      log("Label with #{label}: #{o}")
      super
    end

  end
end
