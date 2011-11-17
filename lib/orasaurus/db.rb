require 'oci8'

module Orasaurus
  
  module DB
  
    class Connection < OCI8
      
      def determine_object_type(object_owner,object_name)
        cursor = self.exec("SELECT object_type FROM ALL_OBJECTS WHERE UPPER(owner) = UPPER(:the_owner) AND UPPER(object_name) = UPPER(:the_object_name)", object_owner, object_name)
        return cursor.fetch().first
      rescue 
        return nil
      end
      
    end
  
  end
  
end