require 'rubygems'
require 'bundler'
Bundler.setup

require 'rake'
require 'rspec/core/rake_task'
require 'rake/gempackagetask'

def gemspec
  eval(File.new('rcelery.gemspec').read)
end
Rake::GemPackageTask.new(gemspec).define

desc 'Run ruby worker integration specs'
RSpec::Core::RakeTask.new('spec:integration:ruby_worker') do |t|
  t.pattern = 'spec/integration/ruby_worker_spec.rb'
  t.rspec_opts = ["--color"]
end

desc 'Run python worker integration specs'
RSpec::Core::RakeTask.new('spec:integration:python_worker') do |t|
  t.pattern = 'spec/integration/ruby_client_python_worker_spec.rb'
  t.rspec_opts = ["--color"]
end

desc 'Run unit specs'
RSpec::Core::RakeTask.new('spec:unit') do |t|
  t.pattern = 'spec/unit/*_spec.rb'
  t.rspec_opts = ["--color"]
end

desc 'Run all specs'
task :spec => ['spec:unit',]

