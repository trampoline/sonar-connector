require 'spec_helper'

describe Sonar::Connector::UpdateStatusCommand do
  
  it "should define constants" do
    Sonar::Connector::CONNECTOR_OK
    Sonar::Connector::CONNECTOR_ERROR
  end
  
  it "update the disk usage statistic" do
    @connector = Object.new
    mock(@connector).name{"name"}
    
    @command = Sonar::Connector::UpdateStatusCommand.new(@connector, Sonar::Connector::CONNECTOR_OK)
    
    @context = Object.new
    @status = Object.new
    mock(@status).set("name", "status", Sonar::Connector::CONNECTOR_OK)
    mock(@context).status{@status}
    
    @command.execute(@context)
  end
  
end