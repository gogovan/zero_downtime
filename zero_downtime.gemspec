# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'zero_downtime/version'

Gem::Specification.new do |spec|
  spec.name          = 'zero_downtime'
  spec.version       = ZeroDowntime::VERSION
  spec.authors       = ['Matthew Rudy Jacobs']
  spec.email         = ['matthewrudyjacobs@gmail.com']

  spec.summary       = <<-SUMMARY.strip
    A simple library for running zero-downtime with Rails and ActiveRecord.
  SUMMARY
  spec.homepage      = 'https://github.com/matthewrudy/zero_downtime'
  spec.license       = 'MIT'
  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport', '>= 3.2.0', '< 5.0.0'
  spec.add_dependency 'activerecord', '>= 3.2.0', '< 5.0.0'

  spec.add_development_dependency 'rubocop', '~> 0.31.0'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'appraisal', '~> 2.0.0'
  spec.add_development_dependency 'bundler', '~> 1.9'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.2.0'
end
