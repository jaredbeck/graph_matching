require_relative '../spec_helper'

describe GraphMatching::Visualize do
  describe '.new' do
    it 'initializes with a graph' do
      g = double
      v = described_class.new(g)
      expect(v.graph).to eq(g)
    end
  end
end
