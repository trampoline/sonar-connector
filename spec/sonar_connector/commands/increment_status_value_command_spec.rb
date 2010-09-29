require 'spec_helper'

describe Sonar::Connector::IncrementStatusValueCommand do
  before do
    setup_valid_config_file
    @base_config = Sonar::Connector::Config.load valid_config_filename
    @status = Sonar::Connector::Status.new @base_config
    stub(@connector = Object.new).name{"name"}
    stub(@context).status{@status}
  end
  
  
  it "should set value if it is nil" do
    @status.set("name", "foo", nil)
    Sonar::Connector::IncrementStatusValueCommand.new(@connector, "foo").execute(@context)
    @status["name"]["foo"].should == 1
  end
  
  it "should increment a value" do
    @status.set "name", "foo", 1
    Sonar::Connector::IncrementStatusValueCommand.new(@connector, "foo").execute(@context)
    @status["name"]["foo"].should == 2
  end
  
end