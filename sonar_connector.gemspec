# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "sonar_connector"
  s.version = "0.10.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Peter MacRobert"]
  s.date = "2013-03-26"
  s.description = "Framework that allows arbitrary push and pull connectors to send data to an instance of the Trampoline SONAR server"
  s.email = "originalpete@gmail.com"
  s.executables = ["sonar-connector"]
  s.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc"
  ]
  s.files = [
    ".rvmrc",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "bin/sonar-connector",
    "config/config.example.json",
    "lib/sonar_connector.rb",
    "lib/sonar_connector/commands/command.rb",
    "lib/sonar_connector/commands/commit_seppuku_command.rb",
    "lib/sonar_connector/commands/increment_status_value_command.rb",
    "lib/sonar_connector/commands/send_admin_email_command.rb",
    "lib/sonar_connector/commands/update_disk_usage_command.rb",
    "lib/sonar_connector/commands/update_status_command.rb",
    "lib/sonar_connector/config.rb",
    "lib/sonar_connector/connectors/base.rb",
    "lib/sonar_connector/connectors/dummy_connector.rb",
    "lib/sonar_connector/connectors/seppuku_connector.rb",
    "lib/sonar_connector/consumer.rb",
    "lib/sonar_connector/controller.rb",
    "lib/sonar_connector/emailer.rb",
    "lib/sonar_connector/rspec/spec_helper.rb",
    "lib/sonar_connector/status.rb",
    "lib/sonar_connector/utils.rb",
    "script/console",
    "spec/sonar_connector/commands/command_spec.rb",
    "spec/sonar_connector/commands/commit_seppuku_command_spec.rb",
    "spec/sonar_connector/commands/increment_status_value_command_spec.rb",
    "spec/sonar_connector/commands/send_admin_email_command_spec.rb",
    "spec/sonar_connector/commands/update_disk_usage_command_spec.rb",
    "spec/sonar_connector/commands/update_status_command_spec.rb",
    "spec/sonar_connector/config_spec.rb",
    "spec/sonar_connector/connectors/base_spec.rb",
    "spec/sonar_connector/connectors/dummy_connector_spec.rb",
    "spec/sonar_connector/connectors/seppuku_connector_spec.rb",
    "spec/sonar_connector/consumer_spec.rb",
    "spec/sonar_connector/controller_spec.rb",
    "spec/sonar_connector/emailer_spec.rb",
    "spec/sonar_connector/status_spec.rb",
    "spec/sonar_connector/utils_spec.rb",
    "spec/spec.opts",
    "spec/spec_helper.rb"
  ]
  s.homepage = "http://github.com/trampoline/sonar-connector"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.24"
  s.summary = "A behind-the-firewall connector for Trampoline SONAR"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<actionmailer>, ["~> 2.3.10"])
      s.add_runtime_dependency(%q<actionmailer_extensions>, ["~> 0.5"])
      s.add_runtime_dependency(%q<json_pure>, [">= 1.2.2"])
      s.add_runtime_dependency(%q<uuidtools>, [">= 2.1.1"])
      s.add_runtime_dependency(%q<sonar_connector_filestore>, ["~> 0.4.0"])
      s.add_development_dependency(%q<rake>, ["~> 10.0.3"])
      s.add_development_dependency(%q<rspec>, ["~> 2.13.0"])
      s.add_development_dependency(%q<rdoc>, ["~> 4.0.0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.3.2"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.8.4"])
      s.add_development_dependency(%q<rr>, [">= 0"])
      s.add_runtime_dependency(%q<actionmailer>, ["~> 2.3.10"])
      s.add_runtime_dependency(%q<actionmailer_extensions>, [">= 0.4.2"])
      s.add_runtime_dependency(%q<json_pure>, [">= 1.2.2"])
      s.add_runtime_dependency(%q<uuidtools>, [">= 2.1.1"])
      s.add_runtime_dependency(%q<sonar_connector_filestore>, [">= 0.1.0"])
      s.add_development_dependency(%q<rspec>, [">= 1.2.8"])
      s.add_development_dependency(%q<rr>, [">= 0.10.5"])
    else
      s.add_dependency(%q<actionmailer>, ["~> 2.3.10"])
      s.add_dependency(%q<actionmailer_extensions>, ["~> 0.5"])
      s.add_dependency(%q<json_pure>, [">= 1.2.2"])
      s.add_dependency(%q<uuidtools>, [">= 2.1.1"])
      s.add_dependency(%q<sonar_connector_filestore>, ["~> 0.4.0"])
      s.add_dependency(%q<rake>, ["~> 10.0.3"])
      s.add_dependency(%q<rspec>, ["~> 2.13.0"])
      s.add_dependency(%q<rdoc>, ["~> 4.0.0"])
      s.add_dependency(%q<bundler>, ["~> 1.3.2"])
      s.add_dependency(%q<jeweler>, ["~> 1.8.4"])
      s.add_dependency(%q<rr>, [">= 0"])
      s.add_dependency(%q<actionmailer>, ["~> 2.3.10"])
      s.add_dependency(%q<actionmailer_extensions>, [">= 0.4.2"])
      s.add_dependency(%q<json_pure>, [">= 1.2.2"])
      s.add_dependency(%q<uuidtools>, [">= 2.1.1"])
      s.add_dependency(%q<sonar_connector_filestore>, [">= 0.1.0"])
      s.add_dependency(%q<rspec>, [">= 1.2.8"])
      s.add_dependency(%q<rr>, [">= 0.10.5"])
    end
  else
    s.add_dependency(%q<actionmailer>, ["~> 2.3.10"])
    s.add_dependency(%q<actionmailer_extensions>, ["~> 0.5"])
    s.add_dependency(%q<json_pure>, [">= 1.2.2"])
    s.add_dependency(%q<uuidtools>, [">= 2.1.1"])
    s.add_dependency(%q<sonar_connector_filestore>, ["~> 0.4.0"])
    s.add_dependency(%q<rake>, ["~> 10.0.3"])
    s.add_dependency(%q<rspec>, ["~> 2.13.0"])
    s.add_dependency(%q<rdoc>, ["~> 4.0.0"])
    s.add_dependency(%q<bundler>, ["~> 1.3.2"])
    s.add_dependency(%q<jeweler>, ["~> 1.8.4"])
    s.add_dependency(%q<rr>, [">= 0"])
    s.add_dependency(%q<actionmailer>, ["~> 2.3.10"])
    s.add_dependency(%q<actionmailer_extensions>, [">= 0.4.2"])
    s.add_dependency(%q<json_pure>, [">= 1.2.2"])
    s.add_dependency(%q<uuidtools>, [">= 2.1.1"])
    s.add_dependency(%q<sonar_connector_filestore>, [">= 0.1.0"])
    s.add_dependency(%q<rspec>, [">= 1.2.8"])
    s.add_dependency(%q<rr>, [">= 0.10.5"])
  end
end

