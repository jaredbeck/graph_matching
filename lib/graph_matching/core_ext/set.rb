require 'set'

# There are some methods we'd like to use which were not added
# until ruby 2.1.  Fortunately, they are implemented in ruby,
# so we can simply copy them.  If we ever drop support for ruby 2.0,
# this file can be deleted.

unless Set.instance_methods.include?(:intersect?)

  # no-doc
  class Set
    # Returns true if the set and the given set have at least one
    # element in common.
    # http://www.ruby-doc.org/stdlib-2.2.0/libdoc/set/rdoc/Set.html#method-i-intersect-3F
    def intersect?(set)
      unless set.is_a?(Set)
        raise ArgumentError, 'value must be a set'
      end
      if size < set.size
        any? { |o| set.include?(o) }
      else
        set.any? { |o| include?(o) }
      end
    end

    # Returns true if the set and the given set have no element in
    # common. This method is the opposite of intersect?.
    # http://www.ruby-doc.org/stdlib-2.2.0/libdoc/set/rdoc/Set.html#method-i-disjoint-3F
    def disjoint?(set)
      !intersect?(set)
    end
  end

end
