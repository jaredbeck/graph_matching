# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'graph_matching/version'

Gem::Specification.new do |spec|
  spec.name = 'graph_matching'
  spec.version = GraphMatching.gem_version.to_s
  spec.authors = ['Jared Beck']
  spec.email = ['jared@jaredbeck.com']
  spec.summary = 'Finds maximum matchings in undirected graphs.'
  spec.description = <<-EOS
    Efficient algorithms for maximum cardinality
    and weighted matchings in undirected graphs.
  EOS
  spec.homepage = 'https://github.com/jaredbeck/graph_matching'
  spec.license = 'MIT'
  spec.files = `git ls-files -z`.split("\x0").reject { |f|
    f.match(%r{^(benchmark|profile|research|spec)/})
  }
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 3.0'
  spec.add_runtime_dependency 'rgl', '~> 0.5.0'
  spec.add_development_dependency 'byebug', '~> 11.0'
  spec.add_development_dependency 'rake', '~> 12.3'
  spec.add_development_dependency 'rspec-core', '~> 3.8'
  spec.add_development_dependency 'rspec-expectations', '~> 3.8'
  spec.add_development_dependency 'rspec-mocks', '~> 3.8'
  spec.add_development_dependency 'rubocop', '~> 1.41.1'
end
