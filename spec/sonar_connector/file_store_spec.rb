require 'spec_helper'

describe Sonar::Connector::FileStore do
  describe "new" do
    
    it "should set base_dir" do
      Sonar::Connector::FileStore.new("foo/").base_dir.should == "foo/"
    end
    
    it "should append trailing slash to base_dir" do
      Sonar::Connector::FileStore.new("bar").base_dir.should == "bar/"
    end
    
    it "should set extension" do
      Sonar::Connector::FileStore.new("foo", ".blah").extension.should == ".blah"
    end
    
    it "should set default extension" do
      Sonar::Connector::FileStore.new("foo").extension.should == ".txt"
    end
  end
  
end
