require 'oci8'
require 'erb'

class TableScriptBuilder
  
  def initialize( db_user, db_password, db_name, output_path )
    
    @db_user = db_user
    @db_password = db_password
    @db_name = db_name
    @output_path = output_path
    
    puts "producing raw table list"
    @raw_table_list = get_table_list
    puts "raw table list count: " + @raw_table_list.length.to_s
    #puts @raw_table_list
    
    puts "producing ordered table list"
    @ordered_table_list = produce_ordered_list
    puts "ordered_table_list count: " + @ordered_table_list.length.to_s
    #puts @ordered_table_list
    
    puts "producing build script"
    @build_script = make_build_script
    
    puts "producing teardown script"
    @teardown_script = make_teardown_script
    
  end
  
  def get_table_list
    
    table_qry = %q{
    SELECT table_name
    FROM user_tables
    WHERE ( table_name LIKE 'FNS%' OR table_name LIKE 'FDR%' )
    }
    
    table_list = Array.new
    
    db_connection = OCI8.new( @db_user, @db_password, @db_name )
    
    db_connection.exec( table_qry ) do |row|
      table_list.push( row.first )
    end
    
    db_connection.logoff
    
    return table_list
    
  end
  
  def get_dependency_list(table_name)

    dependency_qry = %q{ select UNIQUE b.table_name dependent_table
      from user_constraints a
      join user_constraints b
      on a.r_constraint_name = b.constraint_name
      where a.constraint_type = 'R'
      and ( a.table_name LIKE 'FNS%'
        or a.table_name LIKE 'FDR%' )
      and a.table_name = :table_name
      order by b.table_name    
    }
    
    dependency_list = Array.new
    
    db_connection = OCI8.new(@db_user, @db_password, @db_name)

    db_connection.exec(dependency_qry, table_name) do |row|
      dependency_list.push(row.first)
    end
    
    db_connection.logoff
    
    return dependency_list
    
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
  
  def make_build_script
    build_template = %q{
SET SERVEROUTPUT ON
SET DEFINE OFF
SPOOL build.log

PROMPT
PROMPT *****************************GETTING STARTED************************
PROMPT
/
BEGIN DBMS_OUTPUT.PUT_LINE( 'BEGIN TIME: '||TO_CHAR( SYSDATE, 'MM/DD/YYYY HH:MI:SS' ) ); END;
/

<% @ordered_table_list.each do |item| %>
PROMPT
PROMPT ***** <%= item %> ******
PROMPT
@<%= item %>;

<% end %>

BEGIN DBMS_OUTPUT.PUT_LINE( 'END TIME: '||TO_CHAR( SYSDATE, 'MM/DD/YYYY HH:MI:SS' ) ); END;
/
PROMPT
PROMPT *******************************FINISHED*******************************
PROMPT


EXIT
/
		}		
		
		
			script_contents = ERB.new( build_template, nil, ">" ).result(binding)
			script_file = File.new( @output_path + "build.sql", "w" )
			script_file.print( script_contents )
    
  end
  
  def make_teardown_script

teardown_template = %q{
SET SERVEROUTPUT ON
SET DEFINE OFF
SPOOL teardown.log

PROMPT
PROMPT *****************************GETTING STARTED************************
PROMPT
/
BEGIN DBMS_OUTPUT.PUT_LINE( 'BEGIN TIME: '||TO_CHAR( SYSDATE, 'MM/DD/YYYY HH:MI:SS' ) ); END;
/

<% @ordered_table_list.reverse.each do |item| %>
PROMPT
PROMPT <%= item + "\n" %>
PROMPT
DROP TABLE <%= item %> CASCADE CONSTRAINTS;
<% end %>

BEGIN DBMS_OUTPUT.PUT_LINE( 'END TIME: '||TO_CHAR( SYSDATE, 'MM/DD/YYYY HH:MI:SS' ) ); END;
/
PROMPT
PROMPT *******************************FINISHED*******************************
PROMPT


EXIT
/
		}		
		
		
      script_contents = ERB.new( teardown_template, nil, ">" ).result(binding)
			script_file = File.new( @output_path + "teardown.sql", "w" )
			script_file.print( script_contents )
    
  end
  
end
