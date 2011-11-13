require 'rubygems'
require 'bundler/setup'

require File.dirname(__FILE__) + '/../lib/orasaurus.rb'

RSpec.configure do |config|
  # some (optional) config here
end

def cleanup
  puts "deleting all test output files"
  Dir['**/**'].grep(/build\.sql|teardown\.sql/).each { |t| File.delete(t) }
end