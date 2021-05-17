# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = 'fluent-plugin-http'
  spec.version = '1.0.2'
  spec.author = 'Konstantin'
  spec.summary = 'Fluentd output plugin to send logs to an HTTP endpoint'
  spec.license = 'Apache-2.0'
  spec.homepage = 'https://github.com/soylent/fluent-plugin-http'
  spec.required_ruby_version = '>= 2.1', '< 4'
  spec.files = Dir['lib/**/*']
  spec.require_paths = 'lib'
  spec.add_runtime_dependency 'fluentd', ENV.fetch('FLUENTD_VERSION', '>= 0.12')
  spec.add_runtime_dependency 'oj', '~> 3.3'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'test-unit', '~> 3.2'
  spec.add_development_dependency 'webmock', '~> 2.1'
end
