require 'spec_helper'

RSpec.describe GraphMatching::Matching do

  describe '.gabow' do
    context 'when nil is used as a placeholder' do
      it 'returns a Matching' do
        a = [nil, 2, 1, nil, 5, 4]
        m = described_class.gabow(a)
        expect(m).to have_edge([1, 2])
        expect(m).to have_edge([4, 5])
        expect(m).to_not have_vertex(3)
      end
    end

    context 'when 0 is used as a placeholder' do
      it 'returns a Matching' do
        a = [0, 2, 1]
        m = described_class.gabow(a)
        expect(m).to have_edge([1, 2])
        expect(m).to_not have_vertex(3)
      end
    end
  end

  describe '#delete' do
    it 'removes edge' do
      e = [2, 3]
      m = described_class[e]
      expect(m).to have_edge(e)
      m.delete(e)
      expect(m).to_not have_edge(e)
    end
  end

  describe '#empty?' do
    context 'when initialized' do
      it 'returns true' do
        expect(described_class.new.empty?).to eq(true)
      end
    end

    context 'with one or more edges' do
      it 'returns false' do
        expect(described_class[[1,2]].empty?).to eq(false)
      end
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

  describe '#to_a' do
    it 'returns edges' do
      edges = [[1,2], [3,4]]
      m = described_class[*edges]
      expect(m.to_a).to eq(edges)
    end
  end

  describe '#vertexes' do
    it 'returns array of matched vertexes' do
      expect(described_class.new.vertexes).to be_empty
      expect(described_class[[3,4]].vertexes).to match_array([3, 4])
      expect(described_class[[1,2], [3,4]].vertexes).to match_array([1, 2, 3, 4])
    end
  end
end
