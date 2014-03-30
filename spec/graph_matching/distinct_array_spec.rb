require 'spec_helper'

describe GraphMatching::DistinctArray do
  describe '#<<' do
    it 'is the same as Array#<<, but rejects non-distinct elements' do
      p = described_class.new
      expect(p).to eq([])
      expect(p << 1).to eq([1])
      expect(p).to eq([1])
      expect(p << 1).to eq([1])
      expect(p).to eq([1])
      expect(p << 2).to eq([1,2])
      expect(p).to eq([1,2])
    end
  end

  describe '#push' do
    it 'is the same as Array#push, but rejects non-distinct elements' do
      p = described_class.new
      expect(p).to eq([])
      expect(p.push 1).to eq([1])
      expect(p).to eq([1])
      expect(p.push 1).to eq([1])
      expect(p).to eq([1])
      expect(p.push 2).to eq([1,2])
      expect(p).to eq([1,2])
      expect(p.push(2,3)).to eq([1,2,3])
      expect(p).to eq([1,2,3])
    end
  end

  describe '#unshift' do
    it 'is the same as Array#unshift, but rejects non-distinct elements' do
      p = described_class.new
      expect(p).to eq([])
      expect(p.unshift 1).to eq([1])
      expect(p).to eq([1])
      expect(p.unshift 1).to eq([1])
      expect(p).to eq([1])
      expect(p.unshift 2).to eq([2,1])
      expect(p).to eq([2,1])
      expect(p.unshift(2,3)).to eq([3,2,1])
      expect(p).to eq([3,2,1])
    end
  end
end
