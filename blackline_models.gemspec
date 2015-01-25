# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "blackline_models"
  spec.version       = "0.0.1"
  spec.authors       = ["Naren Chainani"]
  spec.email         = ["naren@groupon.com"]
  spec.summary       = "collection of blackline models"
  spec.description   = "collection of blackline models"
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.0"
end
