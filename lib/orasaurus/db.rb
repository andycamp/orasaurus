require 'oci8'

module Orasaurus

#
# A collection of utilities for interacting with Oracle databases  
#
  
  module DB
    
    # Extends oci8 for more info on oci8 read this: http://ruby-oci8.rubyforge.org/en/index.html
    
    class Connection < OCI8
      
      # returns either the object type or nilif the object can't be found
      def determine_object_type(object_owner,object_name)
        cursor = self.exec("SELECT object_type FROM ALL_OBJECTS WHERE UPPER(owner) = UPPER(:the_owner) AND UPPER(object_name) = UPPER(:the_object_name)", object_owner, object_name)
        return cursor.fetch().first
      rescue 
        return nil
      end
      
      # gets a valid dependency list
      # works for any object type
      # for tables, it also searches for foreign key refernces as well as plsql references.
      def get_dependencies(object_owner,object_name)
        tbl_dependency_sql = %q{ select UNIQUE b.table_name dependent_table
          from all_constraints a
          join all_constraints b
          on a.r_constraint_name = b.constraint_name
          where a.constraint_type = 'R'
          and a.owner = upper(:object_owner)
          and a.table_name = upper(:object_name)
          order by b.table_name    
        }
        
        plsql_dependency_sql = %q{ select 
                        referenced_name,
                        referenced_type
                   from all_dependencies
                  where owner = upper(:object_owner)
                    and name = upper(:object_name)
                    and substr(name,1,4) != 'BIN$'
                    and substr(referenced_name,1,4) != 'BIN$'
                    and referenced_type != 'NON-EXISTENT'
                  order by referenced_name    
        }
        
        object_type = determine_object_type(object_owner,object_name)
                
        final_sql = object_type == 'TABLE' ? tbl_dependency_sql : plsql_dependency_sql
        
        dependency_list = []

        self.exec(tbl_dependency_sql,object_owner,object_name) do |row|
          dependency_list.push({ :object_name => row[0], :object_type => row[1]||='TABLE'})
        end
        
        return dependency_list
        
      end
      
    end      
    
    module Builder

        def self.sort(arr,opts={})
        firsts = Array.new
        if tmp = Array.try_convert(opts[:first])
          firsts = opts[:first].to_ary
        elsif tmp = String.try_convert(opts[:first])
          firsts = Array.new.push(opts[:first])
        end

        if opts[:method] == :SQL then
          return self.sort_by_sql(arr, opts[:db_connection])
        else
          return ( firsts + ( arr - firsts ).sort ).compact
        end

      end

      def self.sort_by_sql(arr,dbconnection)
        ordered_list = Array.new
        done_collecting = false
        loop_idx = 0

        while not done_collecting

          loop_idx += 1

          arr.each{ |object|

            if not ordered_list.include?(object) then

              dependency_list = dbconnection.get_dependencies(dbconnection.username,object)
              dependencies = Array.new
              dependency_list.each{ |i| dependencies.push( i.fetch(:object_name).downcase) }
              if dependencies.length == 0 then
                ordered_list.push(object)
              else
                matches = ordered_list.select do |item| 
                  dependencies.include?(item) 
                end
                matches = matches.sort
                if matches.eql?(dependencies)
                  ordered_list.push( object )
                end
              end
            end
          }

          if ordered_list.sort.eql?(arr.sort) then
            done_collecting = true
            puts "done colecting dependency matches. all objects have been collected and matched."
          end

          if loop_idx > 10
            done_collecting = true
            puts "giving up on finishing collection"
            puts "difference (missing ones): "
            puts arr - ordered_list
          end

        end

        return ordered_list

      end

    end
    
  end
  
end