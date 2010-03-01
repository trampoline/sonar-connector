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

require 'sonar_connector/connectors/base'
require 'sonar_connector/connectors/dummy_connector'
require 'sonar_connector/connectors/ping_connector'
require 'sonar_connector/connectors/sonar_connector'
