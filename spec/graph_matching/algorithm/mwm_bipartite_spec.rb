require 'spec_helper'

RSpec.describe GraphMatching::Algorithm::MWMBipartite do

  describe '#match' do
    context 'empty graph'
    context 'trivial bigraph with two vertexes'

    context 'complete bigraph with three vertexes' do
      it 'returns the expected matching' do
        g = GraphMatching::BipartiteGraph[1,2, 1,3]
        g.extend(GraphMatching::Weighted)
        g.set_w([1,2], 1)
        g.set_w([1,3], 2)
        m = described_class.new(g).match
        expect(m.vertexes).to match_array([1,3])
      end
    end

  end

end
