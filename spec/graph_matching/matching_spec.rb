require 'spec_helper'

describe GraphMatching::Matching do
  describe '.new' do
    it 'is a Set' do
      expect(described_class.new).to be_a(Set)
    end
  end

  describe '#augment' do
    it 'augments the matching' do
      m = described_class.new([[2,3]])
      m.augment([1,2,3,4])
      expect(m).to include(match_array([1,2]), match_array([4,3]))
    end
  end

  describe '#has_edge?' do
    it 'returns true if edge found' do
      m = described_class.new
      expect(m).to_not have_edge([1,2])
      m.add([1,2])
      expect(m).to have_edge([1,2])
      m.add([4,3])
      expect(m).to have_edge([3,4])
    end
  end

  describe '#has_vertex?' do
    it 'returns true if vertex found' do
      m = described_class.new
      expect(m).to_not have_vertex(1)
      expect(m).to_not have_vertex(2)
      m.add([1,2])
      expect(m).to have_vertex(1)
      expect(m).to have_vertex(2)
    end
  end

  describe '#match' do
    it 'returns the matched vertex (across the edge) or nil if not matched' do
      m = described_class.new
      expect(m.match(1)).to be_nil
      m.add([1,2])
      expect(m.match(1)).to eq(2)
    end
  end

  describe '#unmatched_vertexes_in' do
    it 'returns unmatched vertexes in the given set' do
      m = described_class.new([[1,2], [3,4]])
      expect(m.unmatched_vertexes_in(Set[1,4,5])).to eq(Set[5])
    end
  end

  describe '#validate' do
    it 'raises an error if a vertex appears more than once' do
      expect {
        described_class.new([[1,2], [3,4]]).validate
      }.to_not raise_error
      expect {
        described_class.new([[1,2], [3,2]]).validate
      }.to raise_error("Invalid matching: A vertex appears more than once.")
    end
  end

end
