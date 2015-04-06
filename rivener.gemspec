# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rivener/version'

Gem::Specification.new do |spec|
  spec.name           = 'rivener'
  spec.summary        = 'Read Scrivener files'
  spec.description    = 'Read Scrivener files'
  spec.platform       = Gem::Platform::RUBY
  spec.version        = Rivener::VERSION
  spec.authors        = ['Dale Emery']
  spec.email          = ['dale@dhemery.com']
  spec.homepage       = 'https://github.com/dhemery/rivener/'
  spec.license        = 'MIT'

  spec.files          = `git ls-files -z`.split("\x0")
  spec.executables    = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files     = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths  = ['lib']

  spec.add_dependency 'liquid', '~> 3.0', '>= 3.0.1'
  spec.add_dependency 'nokogiri', '~> 1.6', '>= 1.6.6'
  spec.add_dependency 'tilt', '~> 2.0', '>= 2.0.1'

  spec.add_development_dependency 'guard', '~> 2.12', '>= 2.12.1'
  spec.add_development_dependency 'guard-minitest', '~> 2.4', '>= 2.4.3'
  spec.add_development_dependency 'minitest-reporters', '~> 1.0', '>= 1.0.8'
end
