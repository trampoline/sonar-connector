begin
  # Try to require the preresolved locked set of gems.
  require File.expand_path('../.bundle/environment', __FILE__)
rescue LoadError
  # Fall back on doing an unlocked resolve at runtime.
  require "rubygems"
  require "bundler"
  Bundler.setup
end

require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "sonar_connector"
    gem.summary = %Q{A behind-the-firewall connector for Trampoline SONAR }
    gem.description = %Q{Framework that allows arbitrary push and pull connectors to send data to an instance of the Trampoline SONAR server }
    gem.email = "peter.macrobert@empire42.com"
    gem.homepage = "http://github.com/trampoline/sonar-connector"
    gem.authors = ["Peter MacRobert", "Mark Meyer"]
    
    gem.add_dependency "activesupport", ">= 2.3.5"
    gem.add_dependency "actionmailer", ">= 2.3.5"
    gem.add_dependency "actionmailer_extensions", ">= 0.2.0"
    gem.add_dependency "json_pure", ">= 1.2.2"
    gem.add_dependency "net-ping", ">= 1.3.2"
    
    gem.add_development_dependency "rspec", ">= 1.2.9"
    gem.add_development_dependency "rr", ">= 0.10.5"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies
task :default => :spec
