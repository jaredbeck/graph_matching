require 'spec_helper'

RSpec.describe GraphMatching::LabelSet do
  let(:label) { double }
  let(:obj) { double }
  let(:set) { described_class.new([], label) }

  describe '.new' do
    it 'initializes with a label' do
      expect(set.label).to eq(label)
    end
  end

  describe '#add' do
    context 'without optional vertex' do
      it 'includes obj' do
        set.add(obj)
        expect(set).to include(obj)
      end
    end
  end

  describe '#get' do
    let(:vertex) { double }

    context 'add obj with optional vertex' do
      it 'labels obj with vertex' do
        set.add(obj, vertex)
        expect(set.get(obj)).to eq(vertex)
      end
    end
  end
end
