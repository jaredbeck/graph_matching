require 'spec_helper'

RSpec.describe GraphMatching::Algorithm::MWMGeneral do
  let(:graph_class) { GraphMatching::Graph::WeightedGraph }

  describe '#match' do
    context 'empty graph' do
      it 'returns empty matching' do
        skip('Coming soon, to a graph near you!')
        g = graph_class.new
        m = described_class.new(g).match
        expect(m).to be_empty
      end
    end
  end
end
