require 'spec_helper'

RSpec.describe GraphMatching do
  describe '.gem_version' do
    it 'returns a Gem::Version' do
      expect(GraphMatching.gem_version).to be_a(Gem::Version)
    end
  end
end
