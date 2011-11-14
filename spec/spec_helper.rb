require 'rubygems'
require 'bundler/setup'

require File.dirname(__FILE__) + '/../lib/orasaurus.rb'

RSpec.configure do |config|
  # some (optional) config heredef capture(stream)
  #lifted from thor's specs
  def capture(stream)
    begin
      stream = stream.to_s
      eval "$#{stream} = StringIO.new"
      yield
      result = eval("$#{stream}").string
    ensure
      eval("$#{stream} = #{stream.upcase}")
    end

    result
  end
end

def cleanup
  puts "deleting all test output files"
  Dir['**/**'].grep(/build\.sql|teardown\.sql/).each { |t| File.delete(t) }
end