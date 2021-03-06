# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'CQHTTP/version'

Gem::Specification.new do |spec|
  spec.name          = 'CQHTTP'
  spec.version       = CQHTTP::VERSION
  spec.authors       = ['71e6fd52']
  spec.email         = ['DAStudio.71e6fd52@gmail.com']

  spec.summary       = 'CoolQ HTTP API ruby bind'
  spec.homepage      = 'https://github.com/71e6fd52/cqhttp-ruby'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.7.0'

  spec.add_development_dependency 'bundler', '~> 2.1'
  spec.add_development_dependency 'rake',    '~> 13.0'
  spec.add_development_dependency 'rspec',   '~> 3.9'

  spec.add_development_dependency 'bump'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'simplecov-lcov'
  spec.add_development_dependency 'solargraph'

  spec.add_dependency 'ruby-dbus', '~> 0.14.0'
end
