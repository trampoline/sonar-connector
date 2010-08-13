module Sonar
  module Connector
    ROOT = File.dirname(__FILE__) unless Sonar::Connector.const_defined?("ROOT")
  end
end

require 'rubygems'
$:.unshift(File.expand_path("..", __FILE__))

# Load external deps
require 'active_support'
require 'json'
require 'yaml'
require 'thread'
require 'logger'
require 'action_mailer'
require 'actionmailer_extensions'
require 'fileutils'
require 'sonar_connector_filestore'

# Load internal classes
%W(
  controller
  config
  status
  consumer
  emailer
  utils
  connectors/base
  connectors/dummy_connector
  commands/command
  commands/update_status_command
  commands/send_admin_email_command
  commands/update_disk_usage_command
  commands/increment_status_value_command
).each do |file|
  require File.join('sonar_connector', file)
end
