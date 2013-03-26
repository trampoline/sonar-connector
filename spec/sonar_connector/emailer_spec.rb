require 'spec_helper'

describe Sonar::Connector::Emailer do
  before do
    setup_valid_config_file
    @base_config = Sonar::Connector::Config.load(valid_config_filename)
    @status = Sonar::Connector::Status.new(@base_config)
    
    @connector = Object.new
    mock(@connector).name(){ "foo_connector" }
    
    ActionMailer::Base.deliveries = []
    ActionMailer::Base.delivery_method.should == :test
    ActionMailer::Base.perform_deliveries.should be_true
    @email = Sonar::Connector::Emailer.create_admin_message(@connector, "the important message")
  end
  
  it "should send" do
    lambda{
      Sonar::Connector::Emailer.deliver(@email)
    }.should change{ActionMailer::Base.deliveries.size}.by(1)
  end
  
  it "should have correct sender" do
    @email.from.size.should == 1
    @email.from.first.should == @base_config.email_settings["admin_sender"]
  end
  
  it "should have correct recipient" do
    @email.to.should == @base_config.email_settings["admin_recipients"].to_a
  end
  
  it "should have the message and connector name in the body" do
    @email.body.should match(/foo_connector/)
    @email.body.should match(/the important message/)
  end
end