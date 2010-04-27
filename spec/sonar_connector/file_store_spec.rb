require 'spec_helper'

describe Sonar::Connector::FileStore do
  describe "new" do
    
    it "should set base_dir" do
      Sonar::Connector::FileStore.new(base_dir+"foo/").base_dir.should == base_dir+"foo/"
    end
    
    it "should append trailing slash to base_dir" do
      Sonar::Connector::FileStore.new(base_dir+"bar").base_dir.should == base_dir+"bar/"
    end
    
    it "should set extension" do
      Sonar::Connector::FileStore.new(base_dir+"foo", ".blah").extension.should == ".blah"
    end
    
    it "should set default extension" do
      Sonar::Connector::FileStore.new(base_dir+"foo").extension.should == ".txt"
    end
  end
  
end
