# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lookout_leonard/version'

Gem::Specification.new do |spec|
  spec.name          = "lookout_leonard"
  spec.version       = LookoutLeonard::VERSION
  spec.authors       = ["Kyle"]
  spec.email         = ["kyle.barton@lookout.com"]
  spec.summary       = %q{Help leonard lookout collect all the things}
  spec.description   = %q{}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"

  spec.add_dependency "gosu"
  spec.add_dependency "rmagick"
  spec.add_dependency "chipmunk"
end
