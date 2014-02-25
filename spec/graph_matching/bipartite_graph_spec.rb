require 'spec_helper'

describe GraphMatching::BipartiteGraph do
  let(:g) { described_class.new }

  it 'is a Graph' do
    expect(g).to be_a(GraphMatching::Graph)
  end

  describe '#maximum_cardinality_matching' do
    context 'empty graph' do
      it 'returns empty set' do
        m = g.maximum_cardinality_matching
        expect(m).to be_a(Set)
        expect(m).to be_empty
      end
    end

    context 'single vertex' do
      it 'returns empty set' do
        g.add_vertex('alice')
        expect(g.maximum_cardinality_matching).to be_empty
      end
    end

    context 'single edge' do
      it 'returns set with one edge' do
        e = ['a', 'b']
        g.add_edge(*e)
        m = g.maximum_cardinality_matching
        expect(m.size).to eq(1)
        expect(m.first).to match_array(e)
      end
    end

    context 'complete bigraph with four vertexes' do
      let(:edges) { [[1,3], [1,4], [2,3], [2,4]] }

      it 'returns one of the two correct results' do
        edges.each { |e| g.add_edge(*e) }
        m = g.maximum_cardinality_matching
        expect(m.size).to eq(2)
        outcomes = [
          RGL::AdjacencyGraph[1,3, 2,4],
          RGL::AdjacencyGraph[1,4, 2,3]
        ]
        reconstructed = RGL::AdjacencyGraph.new
        m.each { |edge| reconstructed.add_edge(*edge) }
        expect(outcomes).to include(reconstructed)
      end
    end

    # The following example is by Derrick Stolee
    # http://www.youtube.com/watch?v=C9c8zEZXboA
    context 'incomplete bigraph with twelve vertexes' do
      let(:edges) {
        [
          [1,8],
          [2,9], [2,10],
          [3,7], [3,9], [3,12],
          [4,8], [4,10],
          [5,10], [5,11],
          [6,11]
        ]
      }

      it 'returns one of the five correct results' do
        edges.each { |e| g.add_edge(*e) }
        m = g.maximum_cardinality_matching
        puts m.inspect
        expect(m.size).to eq(5)
        outcomes = [
          RGL::AdjacencyGraph[1,8, 2,9, 3,7, 5,10, 6,11],
          RGL::AdjacencyGraph[1,8, 2,9, 3,7, 4,10, 5,11],
          RGL::AdjacencyGraph[1,8, 2,9, 3,7, 4,10, 6,11],
          RGL::AdjacencyGraph[1,8, 2,9, 3,12, 4,10, 5,11],
          RGL::AdjacencyGraph[2,9, 3,7, 4,8, 5,10, 6,11]
        ]
        reconstructed = RGL::AdjacencyGraph.new
        m.each { |edge| reconstructed.add_edge(*edge) }
        expect(outcomes).to include(reconstructed)
      end
    end
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
      it 'raises NotBipartiteError' do
        g.add_edge('alice', 'bob')
        g.add_edge('bob', 'carol')
        g.add_edge('alice', 'carol')
        expect { g.partition }.to \
          raise_error(GraphMatching::NotBipartiteError)
      end
    end

    context 'non-trivial bipartite graph' do
      it 'returns the expected disjoint sets' do
        g.add_edge('u1', 'v1')
        g.add_edge('u1', 'v2')
        g.add_edge('u2', 'v1')
        g.add_edge('u2', 'v2')
        p = g.partition
        expect(p[0].to_a).to match_array(%w[u1 u2])
        expect(p[1].to_a).to match_array(%w[v1 v2])
      end
    end

    context 'disconnected graph' do
      it 'raises NotBipartiteError' do
        g.add_edge('a', 'b')
        g.add_edge('c', 'd')
        expect { g.partition }.to \
          raise_error(GraphMatching::NotBipartiteError)
      end
    end
  end
end
