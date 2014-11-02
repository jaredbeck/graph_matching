require 'spec_helper'

RSpec.describe GraphMatching::Weighted do

  class TestGraph
    include GraphMatching::Weighted

    def num_vertices
      13
    end
  end

  let(:g) { TestGraph.new }

  describe '#w' do
    context 'after initialization' do
      it 'returns nil for any edge' do
        1.upto(g.num_vertices) do |i|
          1.upto(g.num_vertices) do |j|
            edge = [i, j]
            expect(g.w(edge)).to be_nil
          end
        end
      end
    end
  end

  describe '#set_w' do
    let(:v) { g.num_vertices }
    let(:edge) { [v - 1, v] }

    it 'records the assigned weight' do
      weight = 7
      g.set_w(edge, weight)
      expect(g.w(edge)).to eq(weight)
    end
  end

end
