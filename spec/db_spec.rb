require 'spec_helper'
require'oci8'

describe Orasaurus::DB do

  before(:all) do
    @sampleDB = Orasaurus::DB::Connection.new("ben","franklin")
  end

  describe "#connect" do
    
    it "should be able to connect to the db." do
      Orasaurus::DB::Connection.new("ben","franklin").should_not be_nil
    end
    
    it "should refuse bad credentials" do
      expect{ Orasaurus::DB::Connection.new("ben","adams") }.to raise_error
    end
    
  end

  describe "#determine_object_type" do
  
    it "should return the appropriate object type." do
      @sampleDB.determine_object_type('ben','notes').should == 'TABLE'
      @sampleDB.determine_object_type('ben','junk').should be_nil
    end

  end
  
  describe "#get_dependencies" do
    
    it "should return the correct depency list for a table" do
      @sampleDB.get_dependencies('ben','notes').first[:object_name].should == 'NOTEBOOKS'
    end
    
  end

  describe Orasaurus::DB::Builder do
    
    describe "#strip_item" do
      
      it "should be able to strip unwanted chars from the item name" do
        Orasaurus::DB::Builder.strip_item("test.sql").should == "test"
        Orasaurus::DB::Builder.strip_item("test.pkg.sql.test").should == "test"
        Orasaurus::DB::Builder.strip_item("test").should == "test"
      end
      
    end

    describe "#sort" do

      it "should default to alphabetic." do
        Orasaurus::DB::Builder.sort(["z","y","x"]).should eql ["x","y","z"]
      end

      it "should be able to always put something first" do
        Orasaurus::DB::Builder.sort([3,2,1], :first => 3).should eql [1,2,3]
        Orasaurus::DB::Builder.sort([4,3,2,1], :first => [4,2] ).should eql [4,2,1,3]
      end

      it "should be able to sort by sql dependencies." do
        Orasaurus::DB::Builder.sort(["note_comments", "notebooks", "notes"], {:method => :SQL, :db_connection => @sampleDB } ).should == [ "notebooks","notes","note_comments"]
        Orasaurus::DB::Builder.sort(["note_comments.trash", "notebooks.trash", "notes.trash"], {:method => :SQL, :db_connection => @sampleDB } ).should == [ "notebooks.trash","notes.trash","note_comments.trash"]
      end

    end

  end

  after(:all) do
    @sampleDB.logoff
  end

end