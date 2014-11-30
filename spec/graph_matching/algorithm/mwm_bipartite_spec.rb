require 'spec_helper'

RSpec.describe GraphMatching::Algorithm::MWMBipartite do

  describe '#match' do
    context 'empty graph' do
      it 'returns the expected matching' do
        g = GraphMatching::BipartiteGraph.new
        g.extend(GraphMatching::Weighted)
        m = described_class.new(g).match
        expect(m.size).to eq(0)
        expect(m.weight(g)).to eq(0)
      end
    end

    context 'trivial bigraph with two vertexes' do
      it 'returns the expected matching' do
        g = GraphMatching::BipartiteGraph[1,2]
        g.extend(GraphMatching::Weighted)
        g.set_w([1,2], 7)
        m = described_class.new(g).match
        expect(m.size).to eq(1)
        expect(m.vertexes).to match_array([1,2])
        expect(m.weight(g)).to eq(7)
      end
    end

    context 'complete bigraph with three vertexes' do
      it 'returns the expected matching' do
        g = GraphMatching::BipartiteGraph[1,2, 1,3]
        g.extend(GraphMatching::Weighted)
        g.set_w([1,2], 1)
        g.set_w([1,3], 2)
        m = described_class.new(g).match
        expect(m.vertexes).to match_array([1,3])
        expect(m.weight(g)).to eq(2)
      end
    end

    context 'bigraph with two connected components' do
      it 'returns the expected matching' do
        g = GraphMatching::BipartiteGraph[1,5, 2,4, 2,6, 3,5]
        g.extend(GraphMatching::Weighted)
        g.set_w([1,5], 3)
        g.set_w([2,4], 2)
        g.set_w([2,6], 2)
        g.set_w([3,5], 3)
        m = described_class.new(g).match
        expect(m.size).to eq(2)
        expect(m.weight(g)).to eq(5)
      end
    end

  end

end
