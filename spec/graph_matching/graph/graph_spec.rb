# encoding: utf-8

require 'spec_helper'

RSpec.describe GraphMatching::Graph::Graph do
  ERR_MSG_INT_VERTEXES = 'All vertexes must be integers'.freeze

  let(:g) { described_class.new }

  it 'is an RGL::MutableGraph' do
    expect(g).to be_a(RGL::MutableGraph)
  end

  describe '.[]' do
    it 'checks that all vertexes are integers' do
      expect { described_class['a', 'b'] }.to \
        raise_error(ArgumentError, ERR_MSG_INT_VERTEXES)
    end
  end

  describe '.new' do
    it 'checks that all vertexes are integers' do
      g1 = RGL::AdjacencyGraph[1, 'b']
      g2 = RGL::AdjacencyGraph['a', 2]
      expect { described_class.new(Set, g1, g2) }.to \
        raise_error(ArgumentError, ERR_MSG_INT_VERTEXES)
    end
  end

  describe '#connected?' do
    it 'returns true for a connected graph' do
      g.add_edge('alice', 'bob')
      expect(g).to be_connected
    end

    it 'returns false for a disconnected graph' do
      g.add_edge('alice', 'bob')
      g.add_edge('yvette', 'zach')
      expect(g).to_not be_connected
    end
  end

  describe '#max_v' do
    it 'returns the largest vertex number' do
      g = described_class[1, 3, 3, 7]
      expect(g.max_v).to eq(7)
    end

    it 'returns nil when graph is empty' do
      expect(g.max_v).to eq(nil)
    end
  end
end
