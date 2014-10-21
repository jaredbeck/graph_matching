$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'graph_matching'
require 'pry'

RSpec.configure do |config|
  config.disable_monkey_patching!
end
