require 'spec_helper'

RSpec.describe GraphMatching::BipartiteGraph do
  let(:g) { described_class.new }

  it 'is a Graph' do
    expect(g).to be_a(GraphMatching::Graph)
  end

  describe '#partition' do
    context 'empty graph' do
      it 'returns two empty sets' do
        p = g.partition
        expect(p.length).to eq(2)
        p.each do |set|
          expect(set).to be_a(Set)
          expect(set).to be_empty
        end
      end
    end

    context 'graph with single edge' do
      it 'returns two disjoint sets, each with one vertex' do
        e = ['alice', 'bob']
        g.add_edge(*e)
        p = g.partition
        expect(p.map(&:first)).to match_array(e)
      end
    end

    context 'complete graph with three vertexes' do
      it 'raises a NotBipartite error' do
        g.add_edge('alice', 'bob')
        g.add_edge('bob', 'carol')
        g.add_edge('alice', 'carol')
        expect { g.partition }.to \
          raise_error(GraphMatching::NotBipartite)
      end
    end

    context 'non-trivial bipartite graph' do
      it 'returns the expected disjoint sets' do
        g.add_edge(1, 3)
        g.add_edge(1, 4)
        g.add_edge(2, 3)
        g.add_edge(2, 4)
        p = g.partition.map(&:sort).sort_by { |v| v.first }
        expect(p).to match_array([[1,2], [3,4]])
      end
    end

    context 'disconnected, yet bipartite graph' do
      it 'returns one of the the expected disjoint sets' do
        g = described_class[1,3, 2,4]
        p = g.partition.map(&:sort).sort_by { |v| v.first }
        permutations = [[[1,2], [3,4]], [[1,4], [2,3]]]
        expect(permutations).to include(p)
      end
    end
  end
end
