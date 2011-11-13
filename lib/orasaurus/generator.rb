require 'find'
require 'erb'

module Orasaurus
  
  # === A basic class used for generating files.
  
  class Generator
    
    attr_reader :name, :build_list
    attr_accessor :output_path, :output_file_name
    
    def initialize(name,output_path,output_file_name,build_list)
      @name = name
      @output_path = output_path
      @output_file_name = output_file_name
      @build_list = build_list
    end
    
    def generate
      puts "undefined"
    end
    
    def full_output_file_name
      @output_path + '/' + @output_file_name
    end
    
  end
  
  class SqlBuildGenerator < Generator

    def generate
      
      if @build_list.empty? then
        puts "nothing in build list. no need for build file."
      else
        
        puts "processing erb for #{@build_list}"
      
        build_template = %q{
SET SERVEROUTPUT ON
SET DEFINE OFF
SPOOL <%=@output_file_name%>.log

PROMPT
PROMPT *****************************GETTING STARTED************************
PROMPT
/
BEGIN DBMS_OUTPUT.PUT_LINE( 'BEGIN TIME: '||TO_CHAR( SYSDATE, 'MM/DD/YYYY HH:MI:SS' ) ); END;
/

<% @build_list.each do |item| %>
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
    
    
        script_contents = ERB.new( build_template, nil, ">" ).result(binding)
        script_file = File.new( full_output_file_name, "w" )
        script_file.print( script_contents )
        puts "creating " + full_output_file_name
      end
    end
    
  end
 
  class SqlTeardownGenerator < Generator
 
    def generate
      
      if @build_list.empty? then
        puts "nothing in build list. no need for build file."
      else
              
        teardown_template = %q{
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
    
        sql_in_clause = ""
        @build_list.each do |i|
          if i == build_list.first then
            sql_in_clause.concat( "'" + i.chomp( File.extname( i ) ).upcase + "'" )
          else
            sql_in_clause.concat( ", '" + i.chomp( File.extname( i ) ).upcase + "'" ) 
          end
        end
    
        script_contents = ERB.new( teardown_template, nil, ">" ).result(binding)
        script_file = File.new( full_output_file_name, "w" )
        script_file.print( script_contents )
        puts "creating " + full_output_file_name
      end
    end		
    
  end

end