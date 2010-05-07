module Sonar
  module Connector
    ROOT = File.dirname(__FILE__) unless Sonar::Connector.const_defined?("ROOT")
  end
end

# Load Bundler
require 'rubygems'

# Load external deps
require 'active_support'
require 'json'
require 'yaml'
require 'thread'
require 'logger'
require 'action_mailer'
require 'actionmailer_extensions'
require 'fileutils'

# Load internal classes
%W(
  controller
  config
  status
  consumer
  emailer
  file_store
  utils
  connectors/base
  connectors/dummy_connector
  commands/command
  commands/update_status_command
  commands/send_admin_email_command
  commands/update_disk_usage_command
  commands/increment_status_value_command
).each do |file|
  require File.expand_path File.join(Sonar::Connector::ROOT, 'sonar_connector', file)
end
