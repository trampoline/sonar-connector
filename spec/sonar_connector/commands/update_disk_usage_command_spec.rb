require 'spec_helper'

describe Sonar::Connector::UpdateDiskUsageCommand do
  
  it "should update the disk usage statistic" do
    @connector = Object.new
    mock(@connector).connector_dir{"dir"}
    mock(@connector).name{"name"}
    
    mock(Sonar::Connector::Utils).du("dir"){2048}
    @command = Sonar::Connector::UpdateDiskUsageCommand.new(@connector)
    
    @context = Object.new
    @status = Object.new
    mock(@status).set("name", "disk_usage", "2 Kb")
    mock(@context).status{@status}
    
    @command.execute(@context)
  end
  
end