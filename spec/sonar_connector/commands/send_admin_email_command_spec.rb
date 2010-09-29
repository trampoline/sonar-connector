require 'spec_helper'

describe Sonar::Connector::SendAdminEmailCommand do
  
  it "should send admin email" do
    @connector = Object.new
    @command = Sonar::Connector::SendAdminEmailCommand.new(@connector, "message")
    
    mock(Sonar::Connector::Emailer).deliver_admin_message(@connector, "message")
    
    @command.execute
  end
  
end