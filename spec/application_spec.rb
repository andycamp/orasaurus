require 'spec_helper'

describe Orasaurus::Application do

  before(:all) do
    cleanup
  end
  
  before(:each) do
    @sampleApp = Orasaurus::Application.new("SampleApp",File.dirname(__FILE__) + '/sampleApp')
  end

  describe "#configuration" do
    
    it "should have a default configuration" do
      @sampleApp.config.should_not be_nil
    end

    it "should be able to override default configuration" do
      @sampleApp.config.custom = true
      @sampleApp.config.custom.should be_true
      @sampleApp.config.custom = false
      @sampleApp.config.custom.should be_false
    end
  
  end
  
  describe "#application" do
  
    it "should be able to discover the buildable directories" do
      @sampleApp.build_dirs.grep(/Notes\/Packages/).should_not be_empty
      @sampleApp.build_dirs.grep(/Notes\/Tables/).should_not be_empty
      @sampleApp.build_dirs.grep(/Notes\/Sequences/).should_not be_empty
    end
    
    it "should be able to connect to a database." do
      @sampleApp.connect("ben","franklin")
      @sampleApp.connection.username.downcase.should == "ben"
    end
  
    it "should be able to sort items in a directory" do
      @sampleApp.connect("ben","franklin")
      build_items = @sampleApp.get_build_items(@sampleApp.build_dirs.grep(/Notes\/Tables/).first, { :method => :SQL } )
      build_items.length.should == 4
      build_items[0].should == "notebooks.sql"
      build_items[1].should == "notes.sql"
    end
  
  end

  describe "#generate" do
    
    it "should be abl'e to generate build scripts" do
      @sampleApp.generate(:build_scripts)
      File.exists?(@sampleApp.base_dir+'/Notes/Packages/build.sql').should be_true
    end
  
    it "should be able to generate teardown scripts" do
      @sampleApp.generate(:teardown_scripts)
      File.exists?(@sampleApp.base_dir+'/Notes/Packages/teardown.sql').should be_true
    end  

  end
  
  after(:all) do
    cleanup
  end
  
end