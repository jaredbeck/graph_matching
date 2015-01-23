require 'spec_helper'

RSpec.describe GraphMatching::Algorithm::MWMGeneral do
  let(:graph_class) { GraphMatching::Graph::WeightedGraph }

  describe '#match' do
    context 'empty graph' do
      it 'returns empty matching' do
        g = graph_class.new
        m = described_class.new(g).match
        expect(m).to be_empty
      end
    end

    context 'single vertex' do
      it 'returns empty matching' do
        g = graph_class.new
        g.add_vertex(1)
        m = described_class.new(g).match
        expect(m).to be_empty
      end
    end

    context 'two vertexes' do
      it 'returns matching of size 1' do
        skip 'Not yet implemented'
        g = graph_class[[1, 2, 1]]
        m = described_class.new(g).match
        expect(m.vertexes).to match_array([1, 2])
        expect(m.weight(g)).to eq(1)
      end
    end

    context 'three vertexes' do
      it 'matches the edge with greater weight' do
        skip 'Not yet implemented'
        g = graph_class[
          [1, 2, 1],
          [2, 3, 2],
          [3, 1, 3]
        ]
        m = described_class.new(g).match
        expect(m.vertexes).to match_array([3, 1])
        expect(m.weight(g)).to eq(3)
      end
    end
  end
end
