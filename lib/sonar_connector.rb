begin
  # Try to require the preresolved locked set of gems.
  require File.expand_path('../.bundle/environment', __FILE__)
rescue LoadError
  # Fall back on doing an unlocked resolve at runtime.
  require "rubygems"
  require "bundler"
  Bundler.setup
end

require 'sonar_connector/controller'
require 'sonar_connector/config'
require 'sonar_connector/base'
require 'sonar_connector/dummy_connector'