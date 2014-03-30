require 'spec_helper'

describe GraphMatching::LabelSet do
  let(:label) { double }
  let(:set) { described_class.new([], label) }

  describe '.new' do
    it 'initializes with a label' do
      expect(set.label).to eq(label)
    end
  end

  describe '#add' do
    let(:obj) { double }

    it 'logs' do
      expect(set).to receive(:log).with("Label with #{label}: #{obj}")
      set.add(obj)
    end
  end
end
