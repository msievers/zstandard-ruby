# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'zstandard/version'

Gem::Specification.new do |spec|
  spec.name          = "zstandard"
  spec.version       = Zstandard::VERSION
  spec.authors       = ["Michael Sievers"]
  spec.email         = ["michael_sievers@web.de"]
  spec.summary       = %q{zstd (Zstandard) compression library bindings}
  spec.description   = %q{This gem provides FFI based Ruby bindings for the zstd (Zstandard) compression library.}
  spec.homepage      = "https://github.com/msievers/zstandard-ruby"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features|bin|benchmarks|run_rspec_with_bundled_libraries.sh)/})
  end

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "ffi", "~> 1.0"
end
