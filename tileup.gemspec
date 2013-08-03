# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tileup/version'

Gem::Specification.new do |spec|
  spec.name        = 'tileup'
  spec.version     = TileUp::VERSION
  spec.date        = '2013-04-16'
  spec.summary     = "Turn an image into an X,Y tile set for use with JS mapping libraries"
  spec.description = spec.summary
  spec.authors     = ["Oliver Marriott"]
  spec.email       = 'hello@omarriott.com'
  spec.homepage    = 'http://github.com/rktjmp/tileup'
  spec.license     = "MIT"
  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.add_runtime_dependency "rmagick", ["~> 2.13.2"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
