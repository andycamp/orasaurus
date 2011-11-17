require 'orasaurus/db'

module Orasaurus
  
  module Build
    
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
            puts "object:#{object} - dependecies:#{dependencies.to_s}"
            if dependencies.length == 0 then
              ordered_list.push(object)
            else
              matches = ordered_list.select do |item| 
                dependencies.include?(item) 
              end
              puts matches.to_s.upcase
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

      puts "ordered list = " + ordered_list.to_s

      return ordered_list
      
    end
    
  end
  
end