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
    let(:vertex) { double }

    context 'with optional vertex' do
      it 'logs obj, label, and vertex' do
        expect(set).to receive(:log).with("Label #{obj} with (#{label}, #{vertex})")
        set.add(obj, vertex)
      end
    end

    context 'without optional vertex' do
      it 'logs obj and label' do
        expect(set).to receive(:log).with("Label #{obj} with (#{label}, )")
        set.add(obj)
      end
    end
  end
end
