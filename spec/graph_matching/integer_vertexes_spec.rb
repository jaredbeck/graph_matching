# frozen_string_literal: true

require 'rgl/adjacency'
require 'spec_helper'
require 'graph_matching/integer_vertexes'

RSpec.describe GraphMatching::IntegerVertexes do
  describe '.to_integers' do
    it 'returns new graph with vertexes converted to integers, and a legend' do
      e = %w[a b]
      g1 = RGL::AdjacencyGraph[*e]
      g2, legend = described_class.to_integers(g1)
      expect(g2.size).to eq(g1.size)
      expect(g2.vertices).to eq(1.upto(g1.size).to_a)
      expect(g2.num_edges).to eq(g1.num_edges)
      legend.keys.map(&:class).uniq.each do |klass|
        expect(klass).to(be <= ::Integer)
      end
    end
  end
end
