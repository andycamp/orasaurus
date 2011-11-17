require 'spec_helper'

describe Orasaurus::Build do

  describe "#sort" do
    
    it "should default to alphabetic." do
      Orasaurus::Build.sort(["z","y","x"]).should eql ["x","y","z"]
    end
    
    it "should be able to always put something first" do
      Orasaurus::Build.sort([3,2,1], :first => 3).should eql [1,2,3]
      Orasaurus::Build.sort([4,3,2,1], :first => [4,2] ).should eql [4,2,1,3]
    end
    
    it "should be able to sort by sql dependencies." do
      con = Orasaurus::DB::Connection.new("ben","franklin")
      Orasaurus::Build.sort(["note_comments", "notebooks", "notes"], {:method => :SQL, :db_connection => con } ).should == [ "notebooks","notes","note_comments"]
    end
    
  end

end