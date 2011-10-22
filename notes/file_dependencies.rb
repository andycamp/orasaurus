class DependencyAnalyzer
  
  def initialize(directory)
    p "Analyzing " + directory
    @search_directory
  end

  def get_file_list
  
  end
  
  def get_dependency_list(file_name)

    
  end
  
  def produce_ordered_list
    
    ordered_list = Array.new
    done_collecting = false
    loop_idx = 0
    
    while not done_collecting
      
      loop_idx += 1
      
      @raw_table_list.each{ |table|
        
        if not ordered_list.include?(table) then
          
          dependencies = get_dependency_list(table).sort
          
          if dependencies.length == 0 then
            ordered_list.push( table )
          else
            #this line of code is checking to see if all of the dependencies
            # for the table we are analyzing are already int the ordered_list
            matches = ordered_list.select{ |i| dependencies.include?(i) }
            matches = matches.sort
            if matches.eql?(dependencies)
              ordered_list.push( table )
            end
          end
        end
        
      }
      
      if ordered_list.sort.eql?(@raw_table_list.sort) then
        done_collecting = true
        puts "done colecting dependency matches. all tables have been collected and matched."
      end

      if loop_idx > 10
        done_collecting = true
        puts "giving up on finishing collecting"
        puts "difference (missing ones): "
        puts @raw_table_list - ordered_list
      end
      
    end
    
    return ordered_list
    
  end
  
