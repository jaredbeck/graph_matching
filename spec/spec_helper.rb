# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'graph_matching'
require 'byebug'

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.filter_run_including(focus: true)
  config.run_all_when_everything_filtered = true
end

RSpec::Matchers.define(:match_edges) do |expected|
  match do |matching|
    raise TypeError unless matching.is_a?(GraphMatching::Matching)
    raise TypeError unless expected.is_a?(Array)
    se = Set.new(expected.map { |e| RGL::Edge::UnDirectedEdge.new(*e) })
    sa = Set.new(matching.undirected_edges)
    se == sa
  end

  failure_message do |matching|
    edges_desc = to_sentence(expected)
    "expected #{matching.edges} to equal" + edges_desc
  end
end
