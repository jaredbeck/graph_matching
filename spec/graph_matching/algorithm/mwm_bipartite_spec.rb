# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GraphMatching::Algorithm::MWMBipartite do
  let(:graph_class) { GraphMatching::Graph::WeightedBigraph }

  describe '.new' do
    it 'requires a WeightedBigraph' do
      expect { described_class.new('banana') }.to raise_error(TypeError)
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
        expect(m).to match_edges [[1, 2]]
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
        expect(m).to match_edges [[1, 3]]
        expect(m.weight(g)).to eq(2)
      end

      it 'supports negative weights' do
        g = graph_class[
          [1, 2, -1],
          [1, 3, -3]
        ]
        m = described_class.new(g).match
        expect(m).to match_edges [[1, 2]]
        expect(m.weight(g)).to eq(-1)
      end
    end

    context 'bigraph with two connected components' do
      it 'returns one of two expected matchings' do
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

      it 'returns the expected matching' do
        g = graph_class[
          [1, 5, 4],
          [2, 4, 2],
          [2, 6, 1],
          [3, 5, 3]
        ]
        m = described_class.new(g).match
        expect(m).to match_edges [[1, 5], [2, 4]]
        expect(m.weight(g)).to eq(6)
      end
    end

    context 'complete graph with three vertexes' do
      # A triangle cannot be bipartite, ie. it is not 2-colorable
      it 'raises NotBipartite error' do
        g = graph_class[
          [1, 2, 1],
          [2, 3, 1],
          [3, 1, 1]
        ]
        expect {
          described_class.new(g).match
        }.to raise_error(GraphMatching::NotBipartite)
      end
    end

    context 'complete bigraph with four vertexes' do
      # An example of a cycle
      it 'returns the expected matching' do
        g = graph_class[
          [1, 2, 2],
          [2, 3, 1],
          [3, 4, 1],
          [4, 1, 1]
        ]
        m = described_class.new(g).match
        expect(m).to match_edges [[1, 2], [3, 4]]
        expect(m.weight(g)).to eq(3)
      end
    end

    context 'issue 10' do
      it 'should not hang forever' do
        skip 'hangs forever'
        g = graph_class[
          [1, 2, 1],
          [3, 2, 1],
          [3, 4, 1],
          [3, 5, 1],
          [6, 2, 1],
          [6, 4, 1],
          [6, 5, 2]
        ]
        described_class.new(g).match
      end
    end
  end
end
