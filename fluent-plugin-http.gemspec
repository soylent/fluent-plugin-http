# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name    = 'fluent-plugin-http'
  spec.version = '0.4.2'
  spec.author  = 'Konstantin'
  spec.summary = 'Fluentd output plugin that sends event records via HTTP'
  spec.license = 'Apache-2.0'

  spec.files = Dir['lib/**/*']
  spec.require_paths = 'lib'

  spec.add_runtime_dependency 'fluentd', ENV.fetch('FLUENTD_VERSION', '~> 0.12')
  spec.add_runtime_dependency 'oj'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 11.3'
  spec.add_development_dependency 'pry', '~> 0.10'
  spec.add_development_dependency 'test-unit', '~> 3.2'
  spec.add_development_dependency 'webmock', '~> 2.1'
  spec.add_development_dependency 'rubocop', '~> 0.45'
end
