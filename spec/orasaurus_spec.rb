require 'spec_helper'

describe "Orasaurus" do

  before(:each) do
    @sampleApp = Orasaurus.new("SampleApp",File.dirname(__FILE__) + '/sampleApp')
  end

  it "should have a default configuration" do
    @sampleApp.config.should_not be_nil
  end
  
  it "should be able to override default configuration" do
    @sampleApp.config.custom = true
    @sampleApp.config.custom.should be_true
    @sampleApp.config.custom = false
    @sampleApp.config.custom.should be_false
  end
  
  it "should be able to discover the buildable directories" do
    @sampleApp.build_dirs.grep(/Notes\/Packages/).should_not be_empty
    @sampleApp.build_dirs.grep(/Notes\/Tables/).should_not be_empty
    @sampleApp.build_dirs.grep(/Notes\/Sequences/).should_not be_empty
  end
  
  it "should be able to generate build scripts" do
    @sampleApp.generate(:build_scripts)
    File.exists?(@sampleApp.base_dir+'Notes/Packages/build.sql').should be_true
  end
  
end