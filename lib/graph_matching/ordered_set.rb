# encoding: utf-8

module GraphMatching

  # An `OrderedSet` acts like a `Set`, but preserves insertion order.
  # Internally, a `Hash` is used because, as of Ruby 1.9, it
  # preserves insertion order.  The Set library happens to be built
  # upon a Hash currently but this might change in the future.
  class OrderedSet
    include Enumerable

    # `.[]` returns a new ordered set containing the given objects.
    # This mimics the signature of `Set.[]` and `Array.[]`.
    def self.[](*args)
      new.merge(args)
    end

    def initialize
      @hash = Hash.new
    end

    # `add` `o` unless it already exists, preserving inserting order.
    # This mimics the signature of `Set#add`.  See alias `#enq`.
    def add(o)
      @hash[o] = true
    end
    alias_method :enq, :add

    def deq
      @hash.keys.first.tap do |k| @hash.delete(k) end
    end

    def each
      @hash.each do |k,v| yield k end
    end

    def empty?
      @hash.empty?
    end

    # `merge` the elements of the given enumerable object to the set
    # and returns self.  This mimics the signature of `Set#merge`.
    def merge(enum)
      enum.each do |e| add(e) end
      self
    end

    # Removes the last element and returns it, or nil if empty.
    # This mimics `Array#pop`.  See related `#deq`.
    def pop
      @hash.keys.last.tap do |k| @hash.delete(k) end
    end

    # `push` appends the given object(s) and returns self.  This
    # mimics the signature of `Array#push`.
    def push(*args)
      merge(args)
    end

  end
end
