# encoding: utf-8

require 'spec_helper'

RSpec.describe GraphMatching::Graph::Weighted do

  class MyGraph < RGL::AdjacencyGraph
    include GraphMatching::Graph::Weighted
  end

  describe '.[]' do
    it 'sets weights' do
      g = MyGraph[[1, 2, 100], [1, 3, 101]]
      expect(g.w([1,2])).to eq(100)
      expect(g.w([1,3])).to eq(101)
    end
  end

  describe '#set_w' do
    let(:g) { MyGraph[[1, 2, 100]] }
    let(:edge) { [1, 2] }

    it 'records the assigned weight' do
      weight = 7
      g.set_w(edge, weight)
      expect(g.w(edge)).to eq(weight)
    end
  end

end
