# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GraphMatching::Algorithm::MCMGeneral do
  let(:graph_class) { GraphMatching::Graph::Graph }
  let(:g) { graph_class.new }

  describe '.new' do
    it 'requires a Graph' do
      expect { described_class.new('banana') }.to raise_error(TypeError)
    end
  end

  describe '#match' do
    def complete_graph(n)
      g = graph_class.new
      1.upto(n - 1) do |i|
        (i + 1).upto(n) do |j|
          g.add_edge(i, j)
        end
      end
      g
    end

    context 'empty graph' do
      it 'returns empty set' do
        expect(described_class.new(g).match).to be_empty
      end
    end

    context 'single vertex' do
      it 'returns empty set' do
        g.add_vertex(1)
        expect(described_class.new(g).match).to be_empty
      end
    end

    context 'two vertexes' do
      let(:g) { graph_class[1, 2] }

      it 'returns one edge' do
        m = described_class.new(g).match
        expect(m.size).to eq(1)
        expect(m).to match_edges [[1, 2]]
      end
    end

    context 'complete graph with four vertexes' do
      it 'returns two disjoint edges' do
        g = graph_class[
          1, 2,
          1, 3,
          1, 4,
          2, 3,
          2, 4,
          3, 4
        ]
        m = described_class.new(g).match
        expect(m.size).to eq(2)
        expect(m.vertexes).to match_array([1, 2, 3, 4])
      end
    end

    context 'graph with stem (123) and blossom (456)' do
      it 'returns an expected result' do
        g = graph_class[
          1, 2,
          2, 3,
          3, 4,
          4, 5,
          5, 6,
          6, 4
        ]
        m = described_class.new(g).match
        expect(m.size).to eq(3)
        expect(m).to match_edges [[1, 2], [3, 4], [5, 6]]
      end
    end

    # TODO: Other algorithms (e.g. both MWM) support disconnected
    # graphs.  MCM General should too.
    context 'disconnected graph' do
      it 'raises a DisconnectedGraph error' do
        2.times { g.add_vertex(double) }
        expect { described_class.new(g).match }.to \
          raise_error(GraphMatching::DisconnectedGraph)
      end
    end

    it 'simple example: graph with blossom (234)' do
      g = graph_class[
        1, 2,
        2, 3,
        2, 4,
        3, 4,
        4, 5,
        5, 6
      ]
      m = described_class.new(g).match
      expect(m.size).to eq(3)
      expect(m).to match_edges [[1, 2], [3, 4], [5, 6]]
    end

    it 'example from West\'s Introduction to Graph Theory, p. 143' do
      g = graph_class[
        1, 2,
        1, 8,
        2, 3,
        3, 4,
        3, 7,
        4, 5,
        4, 7,
        5, 6,
        7, 9,
        8, 9,
        10, 8
      ]
      m = described_class.new(g).match
      expect(m.size).to eq(5)
      expect(m).to match_edges [[1, 2], [3, 4], [5, 6], [7, 9], [8, 10]]
    end

    it 'example from Gabow (1976)' do
      g = graph_class[
        1, 2,
        2, 3,
        1, 3,
        1, 10,
        3, 9,
        3, 4,
        4, 7,
        4, 8,
        7, 8,
        9, 5,
        5, 6,
        6, 7
      ]
      m = described_class.new(g).match
      expect(m).to match_edges [[10, 1], [2, 3], [4, 8], [7, 6], [5, 9]]
    end

    it 'various complete graphs' do
      [
        [1, 0], # size of graph, expected size of matching
        [2, 1],
        [3, 1],
        [4, 2],
        [5, 2],
        [6, 3],
        [20, 10]
      ].each do |test|
        g = complete_graph(test[0])
        m = described_class.new(g).match
        expect(m.size).to eq(test[1])
      end
    end
  end
end
