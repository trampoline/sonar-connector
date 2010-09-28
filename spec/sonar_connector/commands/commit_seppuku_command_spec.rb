require 'spec_helper'

describe Sonar::Connector::CommitSeppukuCommand do
  
  before do
    @connector = Object.new
    @controller = Object.new
    stub(@connector).name{"name"}
  end
  
  it "should update the disk usage statistic" do
    @command = Sonar::Connector::CommitSeppukuCommand.new
    
    @context = Object.new
    @status = Object.new
    @shutdown_lambda = Object.new
    
    mock(@context).controller{@controller}
    mock(@controller).shutdown_lambda{@shutdown_lambda}
    mock(@shutdown_lambda).call
    
    @command.execute(@context)
  end
  
end