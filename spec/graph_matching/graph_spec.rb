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

  describe '#maximal_matching' do
    let(:m) { g.maximal_matching }

    context 'empty graph' do
      it 'returns empty set' do
        expect(m).to be_empty
      end
    end

    context 'single vertex' do
      it 'returns empty set' do
        g.add_vertex(double)
        expect(m).to be_empty
      end
    end

    context 'two vertexes' do
      let(:g) { GraphMatching::Graph[1,2] }

      it 'returns one edge' do
        expect(m.to_a).to eq([[1,2]])
      end
    end

    context 'complete graph with four vertexes' do
      let(:g) { GraphMatching::Graph[1,2, 1,3, 1,4, 2,3, 2,4, 3,4] }

      it 'returns two disjoint edges' do
        expect(m.size).to eq(2)
        expect(m.vertexes).to match_array([1,2,3,4])
      end
    end
  end

  describe '#maximum_cardinality_matching' do
    let(:m) { g.maximum_cardinality_matching }

    context 'empty graph' do
      it 'returns empty set' do
        expect(m).to be_empty
      end
    end

    context 'single vertex' do
      it 'returns empty set' do
        g.add_vertex(double)
        expect(m).to be_empty
      end
    end

    context 'two vertexes' do
      it 'returns one edge'
    end

    context 'complete graph with four vertexes' do
      let(:g) { GraphMatching::Graph[1,2, 1,3, 1,4, 2,3, 2,4, 3,4] }

      it 'returns two disjoint edges' do
        # g.print('v4-1')
        expect(m.size).to eq(2)
      end
    end

    context 'non trivial graph' do
      it 'returns an expected result'
    end

    context 'disconnected graph' do
      it 'raises DisconnectedGraphError' do
        2.times { g.add_vertex(double) }
        expect { m }.to raise_error(GraphMatching::DisconnectedGraphError)
      end
    end
  end
end
