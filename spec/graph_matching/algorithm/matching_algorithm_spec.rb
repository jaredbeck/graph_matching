require 'spec_helper'

RSpec.describe GraphMatching::Algorithm::MatchingAlgorithm do
  let(:algorithm) { described_class.new(double) }

  describe '#assert' do
    it 'returns an Assertion' do
      expect(algorithm.assert('banana')).to \
        be_a(GraphMatching::Assertion)
    end
  end
end
