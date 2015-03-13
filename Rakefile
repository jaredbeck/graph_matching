require "bundler/gem_tasks"
require "rspec/core/rake_task"
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

# TODO: add rubocop as a prerequisite once it's passing.
task :default => [:spec]
