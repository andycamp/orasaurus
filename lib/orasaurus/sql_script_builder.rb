require 'find'
require 'erb'

module Orasaurus
  
  class ScriptBuilder
    
    def initialize( base_directory )

      @base_directory = base_directory
      @ignore_directories = %w(  )
      @ignore_filenames = %w( build.sql teardown.sql build.log teardown.log )
      @buildable_file_extensions = %w( .pkg .pks .pkb .sql .trg )
      @build_directories = Array.new
      @buildable_items = Array.new	
      
      @build_directories = fill_build_directories
      
    end
    
    def fill_build_directories
      return_array = Array.new
      Find.find(@base_directory) do |f|
        if File.directory?( f ) 
          if not @ignore_directories.include?( f.split("/").pop )
            return_array.push( f )
          else
            puts "pruning " + f
            Find.prune
          end
        end
      end
      return return_array
    end
        
    def build_all_scripts(build_file_name, teardown_file_name)
      @build_directories.each do |d|
        @buildable_items = get_buildable_items(d)
        if @buildable_items.length >0 then
          generate_build_script( d + "/" + build_file_name )
          generate_teardown_script( d + "/" + teardown_file_name ) unless d == "DBSeeds"
          #puts "completed working with " + d
        else
          #puts "directory ignored: " + d
        end
      end
    end
        
    def get_buildable_items(dir)
      buildable_items = Array.new
      #puts Dir.glob(dir + "/*.*" )
      if dir.match( /Packages/ )
        search_list = Dir.glob( dir + "/*.pks" ) + Dir.glob( dir + "/*.pkb" ) + Dir.glob( dir + "/*.pkg" )
      else
        search_list = Dir.glob(dir + "/*.*" )
      end
      search_list.each do |f|
        if not File.directory?( f ) \
        and not @ignore_filenames.include?(File.basename( f )) \
        and @buildable_file_extensions.include?(File.extname( f )) \
        then
          buildable_items.push(File.basename( f ))				
        end		
      end
      return buildable_items		
    end
      
    def generate_build_script( output_file_name )
      buildables = @buildable_items
      #puts @buildable_items.inspect
      @build_template = %q{
SET SERVEROUTPUT ON
SET DEFINE OFF
SPOOL build.log

PROMPT
PROMPT *****************************GETTING STARTED************************
PROMPT
/
BEGIN DBMS_OUTPUT.PUT_LINE( 'BEGIN TIME: '||TO_CHAR( SYSDATE, 'MM/DD/YYYY HH:MI:SS' ) ); END;
/

<% buildables.each do |item| %>
PROMPT ***** <%= item %> *****
@<%= item %>;
SHOW ERRORS
<% end %>

BEGIN DBMS_OUTPUT.PUT_LINE( 'END TIME: '||TO_CHAR( SYSDATE, 'MM/DD/YYYY HH:MI:SS' ) ); END;
/
PROMPT
PROMPT *******************************FINISHED*******************************
PROMPT


EXIT
/
    }		
    
    
      script_contents = ERB.new( @build_template, nil, ">" ).result(binding)
      script_file = File.new( output_file_name, "w" )
      script_file.print( script_contents )
      
    end
    
    def generate_teardown_script( output_file_name )
      
      @teardown_template = %q{
    SET	 SERVEROUTPUT ON
    SET DEFINE OFF
    SPOOL teardown.log
    
    DECLARE
      CURSOR cur_drop_list
      IS
        SELECT *
        FROM USER_OBJECTS
        WHERE OBJECT_NAME IN ( <%=@sql_in_clause%> )
        AND OBJECT_TYPE != 'PACKAGE BODY';
      x BOOLEAN := FALSE;    
    BEGIN
      DBMS_OUTPUT.PUT_LINE( 'starting work' );
      FOR i IN cur_drop_list LOOP
        x := TRUE;
        BEGIN
          EXECUTE IMMEDIATE 'DROP '||i.object_type||' '||i.object_name||' CASCADE CONSTRAINTS';
          DBMS_OUTPUT.PUT_LINE( 'DROPPED '||i.object_name );
        EXCEPTION
          WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE( 'WHILE DROPPING '||i.object_type||' '||i.object_name );
            DBMS_OUTPUT.PUT_LINE( SUBSTR( SQLERRM, 1, 255 ) );
        END;
      END LOOP;
      IF NOT x THEN
        DBMS_OUTPUT.PUT_LINE( 'NOTHING FOUND TO DROP' );
      END IF;
      DBMS_OUTPUT.PUT_LINE( 'completed successfully' );  
    END;
    /
    
    EXIT
    /
    }			
    
      @sql_in_clause = ""
      @buildable_items.each do |i|
        if i == @buildable_items.first then
          @sql_in_clause.concat( "'" + i.chomp( File.extname( i ) ).upcase + "'" )
        else
          @sql_in_clause.concat( ", '" + i.chomp( File.extname( i ) ).upcase + "'" ) 
        end
      end
    
      script_contents = ERB.new( @teardown_template, nil, ">" ).result(binding)
      script_file = File.new( output_file_name, "w" )
      script_file.print( script_contents )
    end		
    
  end

end