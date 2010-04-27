require 'spec_helper'

describe Sonar::Connector::FileStore do
  before do
    @filestore = Sonar::Connector::FileStore.new(base_dir+"test-filestore/")
  end
  
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
  
  describe "API" do
    
    describe "files" do
      it "should return empty array when there are no files" do
        glob = File.join @filestore.base_dir, "*", "**"
        Dir[glob].should == []
        @filestore.files.should == []
      end
    
      it "should cache" do
        @filestore.send :clean!
        @filestore.instance_eval do
          @files = ["like", "whatever", "man"]
        end
        @filestore.files.should == ["like", "whatever", "man"]
      end
    
      it "should glob files when cache is dirty" do
        @filestore.send :dirty!
        mock(Dir).glob(anything){["foo", "bar"]}
        @filestore.files.should ==["foo", "bar"]
      end
    end
    
    describe "count" do
      it "should give zero when no files" do
        @filestore.files.should == []
        @filestore.count.should == 0
      end
      
      it "should count files" do
        mock(@filestore).files{["foo", "bar"]}
        @filestore.count.should == 2
      end
    end
    
    describe "add" do
      it "should add content" do
        lambda{
          @filestore.add "content"
        }.should change{@filestore.count}.by(1)
      end
    end
    
    describe "contains" do
      it "should return false if the file is not contained" do
        @filestore.contains?("foobar").should be_false
      end
      
      it "should be true if the file is contained" do
        f = @filestore.add("content")
        @filestore.contains?(f).should be_true
      end
      
      it "should work with basename only" do
        f = File.basename @filestore.add("content")
        @filestore.contains?(f).should be_true
      end
      
      it "should work with a bad path but a correct filename. TODO is this wise?" do
        f = File.basename @filestore.add("content")
        full_path = File.join "foo", "bar", "baz", f
        @filestore.contains?(f).should be_true
      end
    end
    
    describe "move" do
      before do
        @other_filestore = Sonar::Connector::FileStore.new(base_dir+"other-test-filestore/")
        2.times do
          @filestore.add "content"
        end
      end
      
      it "should move the file from one filestore to another" do
        lambda{
          @filestore.move @filestore.files.first, @other_filestore
        }.should change{@filestore.count}.by(-1)
        @other_filestore.count.should == 1
      end
    end
    
    describe "move_all_to" do
      before do
        @other_filestore = Sonar::Connector::FileStore.new(base_dir+"other-test-filestore/")
        2.times do
          @filestore.add "content"
        end
      end
      
      it "should move all files to the other filestore" do
        filestore_old_basenames = @filestore.files.map{|n| File.basename n}
        
        lambda{
          @filestore.move_all_to @other_filestore
        }.should change{@filestore.count}.by(-2)
        @other_filestore.count.should == 2
        
        @other_filestore.files.map{|n| File.basename n}.should == filestore_old_basenames
      end
    end
    
  end
  
  describe "inner workings" do
    
    describe "new_filename" do
      before do
        mock(@uuid = Object.new).to_i{1234567890}
        Sonar::Connector::FileStore::UUID_RADIX = 10
        Sonar::Connector::FileStore::UUID_PAD_LENGTH = 10
        Sonar::Connector::FileStore::DIR_DEPTH = 2
        Sonar::Connector::FileStore::UUID_SLICE_LENGTH = 3
        
        mock(UUIDTools::UUID).timestamp_create{@uuid}
      end
      
      it "should generate a GUID" do
        @filestore.send(:new_filename).should match(/1234567890/)
      end
      
      it "should append full path" do
        p = @filestore.send(:new_filename)
        File.dirname(p).should == File.join(@filestore.base_dir, "123", "456", "789")
      end
      
      it "should append timestamp to the filename" do
        t0 = Time.now
        mock(Time).now{t0}
        p = @filestore.send(:new_filename)
        File.basename(p).should match(/#{t0.to_i}/)
      end
    end
  end
  
end
