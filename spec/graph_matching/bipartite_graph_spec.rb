require 'spec_helper'

describe GraphMatching::BipartiteGraph do
  it 'is a Graph' do
    expect(described_class.new).to be_a(GraphMatching::Graph)
  end
end
