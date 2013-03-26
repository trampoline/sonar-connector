require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "sonar_connector"
    gem.summary = %Q{A behind-the-firewall connector for Trampoline SONAR}
    gem.description = %Q{Framework that allows arbitrary push and pull connectors to send data to an instance of the Trampoline SONAR server}
    gem.email = "originalpete@gmail.com"
    gem.homepage = "http://github.com/trampoline/sonar-connector"
    gem.authors = ["Peter MacRobert"]
    gem.license = "MIT"
    
    gem.add_dependency "actionmailer", "~> 2.3.10"
    gem.add_dependency "actionmailer_extensions", ">= 0.4.2"
    gem.add_dependency "json_pure", ">= 1.2.2"
    gem.add_dependency "uuidtools", ">= 2.1.1"
    gem.add_dependency "sonar_connector_filestore", ">= 0.1.0"
    
    gem.add_development_dependency "rspec", ">= 1.2.8"
    gem.add_development_dependency "rr", ">= 0.10.5"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rspec/core'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec
