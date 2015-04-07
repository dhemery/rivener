require 'rake/clean'
require 'rake/testtask'

gemname = 'rivener'

require_relative "lib/#{gemname}/version"

gemspec = "#{gemname}.gemspec"
gemfile = "#{gemname}-#{Rivener::VERSION}.gem"

task default: :test

desc 'Run all tests'
Rake::TestTask.new do |t|
  t.pattern = "spec/**/*_spec.rb"
end

desc 'Build the gem'
task :build do
  puts %x{ gem build #{gemspec} }
end

desc 'Install the gem'
task install: :build do
  puts %x{ gem install --local #{gemfile} }
end

desc 'Uninstall the gem'
task :uninstall do
  puts %x{ gem uninstall -a -x #{gemname} }
end

CLEAN.include gemfile
