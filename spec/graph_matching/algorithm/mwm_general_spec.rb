# encoding: utf-8

require 'spec_helper'

RSpec.describe GraphMatching::Algorithm::MWMGeneral do
  let(:graph_class) { GraphMatching::Graph::WeightedGraph }

  describe '.new' do
    it 'requires a WeightedGraph' do
      expect { described_class.new("banana") }.to raise_error(TypeError)
    end
  end

  describe '#blossom_leaves' do
    context 'five vertexes, one blossom' do
      it 'returns array of leaves' do
        g = graph_class[
          [0, 1, 0],
          [1, 2, 0],
          [1, 3, 0],
          [2, 3, 0],
          [3, 4, 0]
        ]
        a = described_class.new(g)
        allow(a).to receive(:blossom_children).and_return([
          nil,
          nil,
          nil,
          nil,
          nil,
          [2, 3, 4]
        ])
        expect(a.blossom_leaves(0)).to eq([0])
        expect(a.blossom_leaves(4)).to eq([4])
        expect(a.blossom_leaves(5)).to eq([2, 3, 4])
      end
    end
  end

  describe '#match' do
    context 'empty graph' do
      it 'returns empty matching' do
        g = graph_class.new
        m = described_class.new(g).match(true)
        expect(m).to be_empty
      end
    end

    context 'single vertex' do
      it 'returns empty matching' do
        g = graph_class.new
        g.add_vertex(0)
        m = described_class.new(g).match(true)
        expect(m).to be_empty
      end
    end

    context 'two vertexes' do
      it 'returns matching of size 1' do
        g = graph_class[[0, 1, 7]]
        m = described_class.new(g).match(true)
        expect(m).to match_edges [[0, 1]]
        expect(m.weight(g)).to eq(7)
      end
    end

    context 'three vertexes' do
      it 'matches the edge with greater weight' do
        g = graph_class[
          [0, 1, 1],
          [1, 2, 2],
          [2, 0, 3]
        ]
        m = described_class.new(g).match(true)
        expect(m).to match_edges [[0, 2]]
        expect(m.weight(g)).to eq(3)
      end
    end

    context 'five vertexes, one blossom, three complete matchings with diff. weights' do
      it 'returns the matching with max. weight' do
        g = graph_class[
          [0, 1, 2],
          [1, 2, 0],
          [1, 3, 6], # highest weight edge, but cannot be used in a complete matching
          [2, 3, 4],
          [3, 4, 2]
        ]
        m = described_class.new(g).match(true)
        expect(m).to match_edges [[0, 1], [2, 3]]
        expect(m.weight(g)).to eq(6)
      end
    end

    it "passes Van Rantwijk test 12" do
      g = graph_class[[1, 2, 10], [2, 3, 11]]
      m = described_class.new(g).match(false)
      expect(m).to match_edges [[2, 3]]
      expect(m.weight(g)).to eq(11)
    end

    it "passes Van Rantwijk test 13" do
      g = graph_class[
        [1, 2, 5],
        [2, 3, 11],
        [3, 4, 5]
      ]
      m = described_class.new(g).match(false)
      expect(m).to match_edges [[2, 3]]
      expect(m.weight(g)).to eq(11)
    end

    it "passes Van Rantwijk test 14: max. cardinality" do
      g = graph_class[
        [1, 2, 5],
        [2, 3, 11],
        [3, 4, 5]
      ]
      m = described_class.new(g).match(true)
      expect(m).to match_edges [[1, 2], [3, 4]]
      expect(m.weight(g)).to eq(10)
    end

    it "passes Van Rantwijk test 15: floating-point weights" do
      g = graph_class[
        [1, 2, Math::PI],
        [2, 3, Math.exp(1)],
        [1, 3, 3.0],
        [1, 4, Math.sqrt(2.0)]
      ]
      m = described_class.new(g).match(false)
      expect(m).to match_edges [[1, 4], [2, 3]]
      expect(m.weight(g)).to be_within(0.00001).of(Math.sqrt(2.0) + Math.exp(1))
    end

    it "passes Van Rantwijk test 16: negative weights" do
      g = graph_class[
        [1, 2, 2],
        [1, 3, -2],
        [2, 3, 1],
        [2, 4, -1],
        [3, 4, -6]
      ]
      m = described_class.new(g).match(false)
      expect(m).to match_edges [[1, 2]]
      expect(m.weight(g)).to eq(2)
      m = described_class.new(g).match(true)
      expect(m).to match_edges [[1, 3], [2, 4]]
      expect(m.weight(g)).to eq(-3)
    end

    context "Van Rantwijk test 20: Uses S-blossom for augmentation" do
      it "passes test 20-A" do
        g = graph_class[
          [1, 2, 8],
          [1, 3, 9],
          [2, 3, 10],
          [3, 4, 7]
        ]
        m = described_class.new(g).match(false)
        expect(m).to match_edges [[1, 2], [3, 4]]
        expect(m.weight(g)).to eq(15)
      end

      it "passes test 20-B" do
        g = graph_class[
          [1, 2, 8],
          [1, 3, 9],
          [2, 3, 10],
          [3, 4, 7],
          [1, 6, 5],
          [4, 5, 6]
        ]
        m = described_class.new(g).match(false)
        expect(m).to match_edges [[1, 6], [2, 3], [4, 5]]
        expect(m.weight(g)).to eq(21)
      end
    end

    # Van Rantwijk test 21
    context "create S-blossom, relabel as T-blossom, use for augmentation" do
      it "passes test 21-A" do
        g = graph_class[
          [1, 2, 9],
          [1, 3, 8],
          [2, 3, 10],
          [1, 4, 5],
          [4, 5, 4],
          [1, 6, 3]
        ]
        m = described_class.new(g).match(false)
        expect(m).to match_edges [[1, 6], [2, 3], [4, 5]]
      end

      it "passes test 21-B" do
        g = graph_class[
          [1, 2, 9],
          [1, 3, 8],
          [2, 3, 10],
          [1, 4, 5],
          [4, 5, 3],
          [1, 6, 4]
        ]
        m = described_class.new(g).match(false)
        expect(m).to match_edges [[1, 6], [2, 3], [4, 5]]
      end

      it "passes test 21-C" do
        g = graph_class[
          [1, 2, 9],
          [1, 3, 8],
          [2, 3, 10],
          [1, 4, 5],
          [4, 5, 3],
          [3, 6, 4]
        ]
        m = described_class.new(g).match(false)
        expect(m).to match_edges [[1, 2], [3, 6], [4, 5]]
      end
    end

    context "Van Rantwijk test 22" do
      it "creates nested S-blossom, uses for augmentation" do
        g = graph_class[
          [1, 2, 9],
          [1, 3, 9],
          [2, 3, 10],
          [2, 4, 8],
          [3, 5, 8],
          [4, 5, 10],
          [5, 6, 6]
        ]
        m = described_class.new(g).match(false)
        expect(m).to match_edges [[1, 3], [2, 4], [5, 6]]
      end
    end

  end
end
