require 'spec_helper'

RSpec.describe GraphMatching::Graph do
  let(:g) { described_class.new }

  it 'is an RGL::MutableGraph' do
    expect(g).to be_a(RGL::MutableGraph)
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
end
