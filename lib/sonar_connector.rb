module Sonar
  module Connector
    ROOT = File.dirname(__FILE__)
  end
end

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
require 'active_support'
require 'json'
require 'yaml'
require 'thread'
require 'logger'
require 'action_mailer'
require 'actionmailer_extensions'

class_files = %W(
  controller
  config
  status
  consumer
  emailer
  utils
  connectors/base
  connectors/dummy_connector
  connectors/ping_connector
  commands/command
  commands/update_status_command
  commands/send_admin_email_command
  commands/update_disk_usage_command
)

class_files.each do |file|
  require File.expand_path File.join(Sonar::Connector::ROOT, 'sonar_connector', file)
end
