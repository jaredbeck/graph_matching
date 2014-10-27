require 'spec_helper'

RSpec.describe GraphMatching::Matching do
  describe '.new' do
    it 'is a Set' do
      expect(described_class.new).to be_a(Set)
    end
  end

  describe '#array_match?' do
    it 'returns true if both arrays have same elements, any order' do
      a = [1,2,2,:three]
      b = [2,1,:three,2]
      expect(described_class.new.send(:array_match?, a, b)).to eq(true)
      a = [1,2,2,:three]
      b = [2,1,:three]
      expect(described_class.new.send(:array_match?, a, b)).to eq(false)
    end
  end

  describe '#augment' do
    it 'augments the matching' do
      m = described_class.new([[2,3]])
      m.augment([1,2,3,4])
      expect(m).to include(RGL::Edge::UnDirectedEdge.new(1, 2))
      expect(m).to include(RGL::Edge::UnDirectedEdge.new(4, 3))
      expect(m).to have_edge([1,2])
      expect(m).to have_edge([4,3])
      m.augment([1,2,4,5,6,7])
      expect(m).to include(RGL::Edge::UnDirectedEdge.new(1, 2))
      expect(m).to include(RGL::Edge::UnDirectedEdge.new(4, 5))
      expect(m).to include(RGL::Edge::UnDirectedEdge.new(6, 7))
      expect(m).to have_edge([1,2])
      expect(m).to have_edge([4,5])
      expect(m).to have_edge([6,7])
    end
  end

  describe '#delete' do
    it 'removes edge' do
      e = [2, 3]
      m = described_class.new([e])
      expect(m).to have_edge(e)
      m.delete(e)
      expect(m).to_not have_edge(e)
    end
  end

  describe '#has_any_vertex?' do
    it 'returns true if any given vertexes are matched' do
      m = described_class.new([[2,3], [3,4]])
      expect(m.has_any_vertex?(2, 3)).to eq(true)
      expect(m.has_any_vertex?(4)).to eq(true)
      expect(m.has_any_vertex?(1, 5)).to eq(false)
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

  describe '#vertexes' do
    it 'returns array of matched vertexes' do
      expect(described_class.new.vertexes).to be_empty
      expect(described_class.new([[3,4]]).vertexes).to match_array([3, 4])
      expect(described_class.new([[1,2], [3,4]]).vertexes).to match_array([1, 2, 3, 4])
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
