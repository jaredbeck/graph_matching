# encoding: utf-8

require 'spec_helper'

RSpec.describe GraphMatching::Path do
  describe '.new' do
    it 'raises an error if the path has a length less than two' do
      [[], [1]].each do |ary|
        expected_msg = "Invalid path: Needs at least two vertexes"
        expect { described_class.new(ary) }.to \
          raise_error(ArgumentError, expected_msg)
      end
    end
  end

  describe '#edges' do
    it 'returns an array of edges' do
      expect(described_class.new([1, 2, 3, 4]).edges).to \
        eq([[1, 2], [2, 3], [3, 4]])
    end
  end
end
