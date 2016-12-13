# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'zstandard/version'

Gem::Specification.new do |spec|
  spec.name          = "zstandard"
  spec.version       = Zstandard::VERSION
  spec.authors       = ["Michael Sievers"]
  spec.email         = ["michael_sievers@web.de"]
  spec.summary       = %q{Zstandard compression library bindings}
  spec.homepage      = "https://github.com/msievers/zstandard"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "ffi", "~> 1.0"
end
