# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'upnp_content_explorer'

Gem::Specification.new do |spec|
  spec.name          = "upnp_content_explorer"
  spec.version       = UpnpContentExplorer::VERSION
  spec.authors       = ["Christopher Mullins"]
  spec.email         = ["chris@sidoh.org"]

  spec.summary       = %q{Provides a convenient way to explore and access content provided by a UPnP media server.}
  spec.homepage      = "http://www.github.com/sidoh/upnp_content_explorer"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "nori", "~> 2.6"
  spec.add_dependency "easy_upnp", "~> 0.1"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.3"
end
