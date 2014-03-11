require 'spec_helper'

describe GraphMatching::DisjointSet do
  describe '#connected?(i, j)' do
    it 'returns true if i and j share a "leader"' do
      d = described_class.new 10
      expect(d.connected?(1,4)).to eq(false)
      expect(d.connected?(5,1)).to eq(false)
      expect(d.connected?(2,4)).to eq(false)

      d.union(1,4) # "leader" of 4 is now 1
      expect(d.connected?(1,4)).to eq(true)
      expect(d.connected?(5,1)).to eq(false)
      expect(d.connected?(2,4)).to eq(false)

      d.union(4,5) # "leader" of 5 is now 1
      expect(d.connected?(1,4)).to eq(true)
      expect(d.connected?(5,1)).to eq(true)
      expect(d.connected?(2,4)).to eq(false)
    end
  end
end
