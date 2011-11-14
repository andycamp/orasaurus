require 'spec_helper'

describe Orasaurus::Build do

  describe "#sort" do
    
    it "should default to alphabetic." do
      Orasaurus::Build.sort(["z","y","x"]).should eql ["x","y","z"]
    end
    
    it "should be able to always put something first" do
      Orasaurus::Build.sort(["z","y","x"], :first => "z" ).should eql ["z","x","y"]
      Orasaurus::Build.sort(["z","y","x","w"], :first => ["z", "w"] ).should eql ["z","w","x","y"]
    end
    
  end

end