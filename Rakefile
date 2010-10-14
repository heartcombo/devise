# encoding: UTF-8

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require File.join(File.dirname(__FILE__), 'lib', 'devise', 'version')

desc 'Default: run tests for all ORMs.'
task :default => :pre_commit

desc 'Run Devise tests for all ORMs.'
task :pre_commit do
  Dir[File.join(File.dirname(__FILE__), 'test', 'orm', '*.rb')].each do |file|
    orm = File.basename(file).split(".").first
    system "rake test DEVISE_ORM=#{orm}"
  end
end

desc 'Run Devise unit tests.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for Devise.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Devise'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    root_files = FileList["README.rdoc", "MIT-LICENSE", "CHANGELOG.rdoc"]
    s.name = "devise"
    s.version = Devise::VERSION.dup
    s.summary = "Flexible authentication solution for Rails with Warden"
    s.email = "contact@plataformatec.com.br"
    s.homepage = "http://github.com/plataformatec/devise"
    s.description = "Flexible authentication solution for Rails with Warden"
    s.authors = ['José Valim', 'Carlos Antônio']
    s.files =  root_files + FileList["{app,config,lib}/**/*"]
    s.extra_rdoc_files = root_files
    s.add_dependency("warden", "~> 1.0.0")
    s.add_dependency("orm_adapter", "~> 0.0.2")
    s.add_dependency("bcrypt-ruby", "~> 2.1.2")
  end

  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: gem install jeweler"
end
