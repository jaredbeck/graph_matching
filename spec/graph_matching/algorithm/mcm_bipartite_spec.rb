# encoding: utf-8

require 'spec_helper'

RSpec.describe GraphMatching::Algorithm::MCMBipartite do
  let(:g) { GraphMatching::Graph::Bigraph.new }

  describe '.new' do
    it 'requires a Bigraph' do
      expect { described_class.new("banana") }.to raise_error(TypeError)
    end
  end

  describe '#augment' do
    it 'augments the matching' do
      mcm = described_class.new(g)
      m = [nil, nil, 3, 2]
      m = mcm.send(:augment, m, [1,2,3,4])
      expect(m).to eq([nil, 2, 1, 4, 3])
      m = mcm.send(:augment, m, [1,2,4,5,6,7])
      expect(m).to eq([nil, 2, 1, nil, 5, 4, 7, 6])
    end
  end

  describe '#match' do
    context 'empty graph' do
      it 'returns empty set' do
        m = described_class.new(g).match
        expect(m).to be_empty
      end
    end

    context 'single vertex' do
      it 'returns empty set' do
        g.add_vertex(0)
        expect(described_class.new(g).match).to be_empty
      end
    end

    context 'single edge' do
      it 'returns set with one edge' do
        e = [1, 2]
        g.add_edge(*e)
        m = described_class.new(g).match
        expect(m.size).to eq(1)
        expect(m).to have_edge(e)
      end
    end

    context 'complete bigraph with four vertexes' do
      let(:edges) { [[1,3], [1,4], [2,3], [2,4]] }

      it 'returns one of the two correct results' do
        edges.each { |e| g.add_edge(*e) }
        m = described_class.new(g).match
        expect(m.size).to eq(2)
        outcomes = [
          RGL::AdjacencyGraph[1,3, 2,4],
          RGL::AdjacencyGraph[1,4, 2,3]
        ]
        reconstructed = RGL::AdjacencyGraph.new
        m.to_a.each { |edge| reconstructed.add_edge(*edge) }
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
        m = described_class.new(g).match
        expect(m.size).to eq(5)
        outcomes = [
          RGL::AdjacencyGraph[1,8, 2,9, 3,7, 5,10, 6,11],
          RGL::AdjacencyGraph[1,8, 2,9, 3,7, 4,10, 5,11],
          RGL::AdjacencyGraph[1,8, 2,9, 3,7, 4,10, 6,11],
          RGL::AdjacencyGraph[1,8, 2,9, 3,12, 4,10, 5,11],
          RGL::AdjacencyGraph[2,9, 3,7, 4,8, 5,10, 6,11]
        ]
        reconstructed = RGL::AdjacencyGraph.new
        m.to_a.each { |edge| reconstructed.add_edge(*edge) }
        expect(outcomes).to include(reconstructed)
      end
    end
  end
end
