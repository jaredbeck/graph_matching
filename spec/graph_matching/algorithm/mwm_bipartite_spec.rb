# encoding: utf-8

require 'spec_helper'

RSpec.describe GraphMatching::Algorithm::MWMBipartite do
  let(:graph_class) { GraphMatching::Graph::WeightedBigraph }

  describe '.new' do
    it 'requires a WeightedBigraph' do
      expect { described_class.new("banana") }.to raise_error(TypeError)
    end
  end

  describe '#match' do
    context 'empty graph' do
      it 'returns the expected matching' do
        g = graph_class.new
        m = described_class.new(g).match
        expect(m.size).to eq(0)
        expect(m.weight(g)).to eq(0)
      end
    end

    context 'trivial bigraph with two vertexes' do
      it 'returns the expected matching' do
        g = graph_class[[1, 2, 7]]
        m = described_class.new(g).match
        expect(m.size).to eq(1)
        expect(m.vertexes).to match_array([1,2])
        expect(m.weight(g)).to eq(7)
      end
    end

    context 'complete bigraph with three vertexes' do
      it 'returns the expected matching' do
        g = graph_class[
          [1, 2, 1],
          [1, 3, 2]
        ]
        m = described_class.new(g).match
        expect(m.vertexes).to match_array([1,3])
        expect(m.weight(g)).to eq(2)
      end

      it 'supports negative weights' do
        g = graph_class[
          [1, 2, -1],
          [1, 3, -3]
        ]
        m = described_class.new(g).match
        expect(m.vertexes).to match_array([1,2])
        expect(m.weight(g)).to eq(-1)
      end
    end

    context 'bigraph with two connected components' do
      it 'returns the expected matching' do
        g = graph_class[
          [1, 5, 3],
          [2, 4, 2],
          [2, 6, 2],
          [3, 5, 3]
        ]
        m = described_class.new(g).match
        expect(m.size).to eq(2)
        expect(m.weight(g)).to eq(5)
      end
    end
  end

end
