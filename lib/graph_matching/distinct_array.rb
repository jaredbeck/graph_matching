module GraphMatching
  class DistinctArray < Array
    def <<(v)
      include?(v) ? self : super
    end

    def push(*v)
      super(*v.reject { |i| include?(i) })
    end

    def unshift(*v)
      super(*v.reject { |i| include?(i) })
    end
  end
end
