# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rubocop/rake_task'

Rake::TestTask.new do |test_task|
  test_task.libs << 'test'
  test_task.test_files = FileList['test/plugin/test_*.rb']
end

RuboCop::RakeTask.new

task default: %i[test rubocop]
