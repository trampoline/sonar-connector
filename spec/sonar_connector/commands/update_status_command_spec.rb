require 'spec_helper'

describe Sonar::Connector::UpdateStatusCommand do
  
  it "should define constants" do
    Sonar::Connector::ACTION_OK
    Sonar::Connector::ACTION_FAILED
  end
  
  it "update the disk usage statistic" do
    @connector = Object.new
    mock(@connector).name{"name"}
    
    @command = Sonar::Connector::UpdateStatusCommand.new(@connector, "last_operation", Sonar::Connector::ACTION_OK)
    
    @context = Object.new
    @status = Object.new
    mock(@status).set("name", "last_operation", Sonar::Connector::ACTION_OK)
    mock(@context).status{@status}
    
    @command.execute(@context)
  end
  
end