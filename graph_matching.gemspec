# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'graph_matching/version'

Gem::Specification.new do |spec|
  spec.name          = 'graph_matching'
  spec.version       = GraphMatching::VERSION
  spec.authors       = ['Jared Beck']
  spec.email         = ['jared@jaredbeck.com']
  spec.summary       = 'Finds maximum matchings in undirected graphs.'
  spec.description   = <<-EOS
    Implements modern algorithms for finding maximum cardinality
    and maximum weighted matchings in undirected graphs and bigraphs.
  EOS
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.1.0'

  spec.add_runtime_dependency 'rgl', '~> 0.4.0'

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rspec-core', '~> 3.0.0.beta2'
  spec.add_development_dependency 'rspec-expectations', '~> 3.0.0.beta2'
  spec.add_development_dependency 'rspec-mocks', '~> 3.0.0.beta2'
end
