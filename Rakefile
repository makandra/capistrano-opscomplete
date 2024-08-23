require 'rubocop/rake_task'
require 'bundler/gem_tasks'

RuboCop::RakeTask.new(:rubocop) do |task|
  # task.requires << 'rubocop-rake'
  task.patterns = ['lib/**/*.rb']
  # task.formatters = ['files']
end

task default: [:rubocop]
