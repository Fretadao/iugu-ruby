# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'iugu/version'

Gem::Specification.new do |spec|
  spec.name          = 'iugu'
  spec.version       = Iugu::VERSION
  spec.authors       = ['Marcelo Paez Sequeira']
  spec.email         = ['marcelo@iugu.com']
  spec.summary       = %q{Iugu API}
  spec.homepage      = 'https://iugu.com'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'rest-client'
  spec.add_dependency 'cpf_cnpj'
  spec.add_dependency 'openssl'
  spec.add_dependency 'base64'
  spec.add_dependency 'time'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'vcr'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-nav'
end
