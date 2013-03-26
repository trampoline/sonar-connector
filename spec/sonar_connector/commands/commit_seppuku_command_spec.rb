require 'spec_helper'

describe Sonar::Connector::CommitSeppukuCommand do
  
  before do
    @connector = Object.new
    @controller = Object.new
    stub(@connector).name{"name"}
  end
  
  it "should run the shutdown lambda" do
    @command = Sonar::Connector::CommitSeppukuCommand.new
    
    @context = Object.new
    @status = Object.new
    @shutdown_lambda = Object.new
    
    mock(@context).controller{@controller}
    mock(@controller).shutdown_lambda{@shutdown_lambda}
    mock(@shutdown_lambda).call
    
    @command.execute(@context)
    sleep(1)
  end
  
end