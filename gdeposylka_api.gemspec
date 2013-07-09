# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gdeposylka_api/version'

Gem::Specification.new do |spec|

  spec.name          = "gdeposylka_api"
  spec.version       = GdeposylkaApi::VERSION
  spec.authors       = ["Ivan Piliaiev"]
  spec.email         = ["piliaiev@gmail.com"]
  spec.description   = %q{API for gdeposylka.ru}
  spec.summary       = %q{API for gdeposylka.ru}
  spec.homepage      = "https://github.com/dancingbytes/gdeposylka_api"
  spec.license       = "BSD"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_dependency "json"

end
