require_relative '../spec_helper'

describe GraphMatching::Visualize do
  describe '.new' do
    it 'initializes with a graph' do
      g = double
      v = described_class.new(g)
      expect(v.graph).to eq(g)
    end
  end

  describe '#dot' do
    let(:g) { GraphMatching::Graph.new }

    def normalize_ws(str)
      str.gsub(/\s+/, ' ').strip
    end

    it 'returns a string in .dot format' do
      g.add_edge('alice', 'bob')
      str = described_class.new(g).dot
      expect(normalize_ws(str)).to eq('strict graph G { alice--bob }')
    end
  end
end
