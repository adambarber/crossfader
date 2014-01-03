# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'crossfader/version'

Gem::Specification.new do |spec|
  spec.name          = "crossfader"
  spec.version       = Crossfader::VERSION
  spec.authors       = ["Adam Barber"]
  spec.email         = ["adam@adambarber.tv"]
  spec.description   = ["Crossfader allows for easy batch conversion and upload of loops for Crossfader.fm"]
  spec.summary       = ["Quickly convert and upload loops for Crossfader.fm"]
  spec.homepage      = "http://crossfader.fm"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_dependency 'thor', ['>= 0.18.1', '< 2']
  spec.add_dependency 'lame'
end
