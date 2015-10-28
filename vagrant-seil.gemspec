lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vagrant-seil/version'

Gem::Specification.new do |spec|
  spec.name          = "vagrant-seil"
  spec.version       = VagrantPlugins::Seil::VERSION
  spec.authors       = ["Tomoyuki Sahara"]
  spec.email         = ["tsahara@iij.ad.jp"]
  spec.description   = %q{Vagrant Plugin for SEIL/x86.}
  spec.summary       = %q{Vagrant Plugin for SEIL/x86.}
  spec.homepage      = "https://github.com/iij/vagrant-seil"
  spec.license       = "MIT"

  spec.files         = `git ls-files Gemfile lib locales *.gemspec`.split($/)
  #spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
end
