require 'spec_helper'

describe GraphMatching::Graph do
  let(:g) { described_class.new }

  it 'is an RGL::MutableGraph' do
    expect(g).to be_a(RGL::MutableGraph)
  end

  describe '#connected?' do
    it 'returns true for a connected graph' do
      g.add_edge('alice', 'bob')
      expect(g).to be_connected
    end

    it 'returns false for a disconnected graph' do
      g.add_edge('alice', 'bob')
      g.add_edge('yvette', 'zach')
      expect(g).to_not be_connected
    end
  end

  describe '#maximum_cardinality_matching' do

    def complete_graph(n)
      g = GraphMatching::Graph.new
      1.upto(n - 1) do |i|
        (i + 1).upto(n) do |j|
          g.add_edge(i, j)
        end
      end
      g
    end

    context 'empty graph' do
      it 'returns empty set' do
        expect(g.maximum_cardinality_matching).to be_empty
      end
    end

    context 'single vertex' do
      it 'returns empty set' do
        g.add_vertex(1)
        expect(g.maximum_cardinality_matching).to be_empty
      end
    end

    context 'two vertexes' do
      let(:g) { GraphMatching::Graph[1,2] }

      it 'returns one edge' do
        expect(g.maximum_cardinality_matching.size).to eq(1)
        expect(g.maximum_cardinality_matching.vertexes).to match_array([1,2])
      end
    end

    context 'complete graph with four vertexes' do
      let(:g) { GraphMatching::Graph[1,2, 1,3, 1,4, 2,3, 2,4, 3,4] }

      it 'returns two disjoint edges' do
        # g.print('v4-1')
        expect(g.maximum_cardinality_matching.size).to eq(2)
        expect(g.maximum_cardinality_matching.vertexes).to match_array([1,2,3,4])
      end
    end

    context 'graph with stem (123) and blossom (456)' do
      let(:g) { GraphMatching::Graph[1,2, 2,3, 3,4, 4,5, 5,6, 6,4] }

      it 'returns an expected result' do
        expect(g.maximum_cardinality_matching.size).to eq(3)
        expect(g.maximum_cardinality_matching.vertexes).to match_array([1,2,3,4,5,6])
      end
    end

    context 'disconnected graph' do
      it 'raises a DisconnectedGraph error' do
        2.times { g.add_vertex(double) }
        expect { g.maximum_cardinality_matching }.to \
          raise_error(GraphMatching::DisconnectedGraph)
      end
    end

    it 'simple example: graph with stem (123) and blossom (345)' do
      g = GraphMatching::Graph[1,2, 2,3, 2,4, 3,4, 4,5, 5,6]
      m = g.maximum_cardinality_matching
      expect(m.size).to eq(3)
      expect(m.vertexes).to match_array(g.to_a)
    end

    it 'example from West\'s Introduction to Graph Theory, p. 143' do
      g = GraphMatching::Graph[1,2, 1,8, 2,3, 3,4, 3,7, 4,5, 5,6, 7,9, 8,9, 10,8]
      m = g.maximum_cardinality_matching
      expect(m.size).to eq(5)
      expect(m.vertexes).to match_array(g.vertexes)
    end

    it 'example from Gabow (1976)' do
      g = GraphMatching::Graph[1,2, 2,3, 1,3, 1,10, 3,9, 3,4, 4,7, 4,8, 7,8, 9,5, 5,6, 6,7]
      m = g.maximum_cardinality_matching
      expect(m.size).to eq(5)
      expect(m.vertexes).to match_array(1.upto(10))
      expected = [[10,1], [2,3], [4,8], [7,6], [5,9]]
      expected.each do |edge|
        expect(m).to have_edge(edge)
      end
    end

    it 'various complete graphs' do
      expect(complete_graph(1).maximum_cardinality_matching.size).to eq(0)
      expect(complete_graph(2).maximum_cardinality_matching.size).to eq(1)
      expect(complete_graph(3).maximum_cardinality_matching.size).to eq(1)
      expect(complete_graph(4).maximum_cardinality_matching.size).to eq(2)
      expect(complete_graph(5).maximum_cardinality_matching.size).to eq(2)
      expect(complete_graph(6).maximum_cardinality_matching.size).to eq(3)
      expect(complete_graph(20).maximum_cardinality_matching.size).to eq(10)
    end
  end
end
