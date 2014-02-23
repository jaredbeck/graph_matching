require 'spec_helper'

describe GraphMatching::Graph do
  it 'is an RGL::MutableGraph' do
    expect(described_class.new).to be_a(RGL::MutableGraph)
  end
end
