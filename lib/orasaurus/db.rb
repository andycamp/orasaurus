require 'oci8'

module Orasaurus

  module Db
        
    def self.compile(connection, sql)
      puts "compiling"
      connection.exec("#{sql}")
    end      
      
  end
  
end
