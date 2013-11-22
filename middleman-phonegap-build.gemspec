# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'middleman-phonegap-build/pkg-info'

Gem::Specification.new do |s|
  s.name        = Middleman::PhonegapBuild::PACKAGE
  s.version     = Middleman::PhonegapBuild::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = %w('Roelof Reitsma')
  s.email       = %w(roelof.reitsma@gmail.com)
  s.homepage    = 'http://github.com/ryreitsma/middleman-phonegap-build'
  s.summary     = Middleman::PhonegapBuild::TAGLINE
  s.description = Middleman::PhonegapBuild::TAGLINE
  s.license     = 'MIT'

  s.files         = `git ls-files`.split('\n')
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split('\n')
  s.executables   = `git ls-files -- bin/*`.split('\n').map{ |f| File.basename(f) }
  s.require_paths = %w(lib)

  # The version of middleman-core your extension depends on
  s.add_runtime_dependency('middleman-core', ['>= 3.0.0'])

  # Additional dependencies
  s.add_runtime_dependency('ptools')
  s.add_runtime_dependency('net-sftp')
end
