lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'synapse_pay_rest/version'

Gem::Specification.new do |s|
  s.name        = 'synapse_pay_rest'
  s.version     = SynapsePayRest::VERSION
  s.date        = Date.today.to_s
  s.summary     = "SynapsePay v3 Rest API Wrapper"
  s.description = "A simple ruby wrapper for the SynapsePay v3 Rest API"
  s.authors     = ["Thomas Hipps", "Steven Broderick"]
  s.email       = 'steven@synapsepay.com'
  s.homepage    = 'https://rubygems.org/gems/synapse_pay_rest'
  s.license     = 'MIT'

  s.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  s.bindir        = "exe"
  s.executables   = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "bundler", "~> 1.10"
  s.add_development_dependency "rake", "~> 10.0"
  s.add_development_dependency "minitest"
  s.add_development_dependency "minitest-reporters"

  s.add_dependency "rest-client"
end
