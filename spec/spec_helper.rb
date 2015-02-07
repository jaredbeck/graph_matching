# encoding: utf-8

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'graph_matching'
require 'pry'

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.filter_run_including(focus: true)
  config.run_all_when_everything_filtered = true
end
