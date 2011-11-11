require 'orasaurus/sql_script_builder'
require 'orasaurus/version'
require 'orasaurus/cli'
require 'orasaurus/cofigration'

module Orasaurus

  def self.configuration
    @configuration ||= Orasaurus::Configure.new
  end

  def self.configure
    yield configuration if block_given?
  end

	def self.sync_build_scripts(*args)
		args = args
    p args
	end

end


