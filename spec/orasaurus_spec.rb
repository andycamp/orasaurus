require 'spec_helper'

describe "Orasaurus" do

  it "should be able to create an Oracle object from a file" do
    Orasaurus.compile( "franklin" )
    Orasaurus.compile( "franklin" ).should == "franklin"
  end
  
end

puts "franklin"