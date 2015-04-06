require 'rake/clean'
require 'rake/testtask'

require_relative 'lib/dhepub/version'

gemname = 'dhepub'
gemspec = "#{gemname}.gemspec"
gemfile = "#{gemname}-#{DHEpub::VERSION}.gem"

book_files = "examples/dale-template/"
epub_file = "raked-example.epub"

task default: :test

desc 'Run all unit and integration tests'
task all: [:clean, :test, :epub, :check]

desc 'Run epubcheck on the example epub file'
task :check do
  puts %x{ epubcheck #{epub_file} }
end

desc 'Build an example epub file'
task :epub do
  puts %x{ dhepub -o #{epub_file} #{book_files} }
end

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

CLEAN.include epub_file, gemfile
