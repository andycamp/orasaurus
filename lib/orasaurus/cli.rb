require 'highline'
require 'thor'
require 'orasaurus/version'
require 'orasaurus/application'
    
module Orasaurus

  class CLI < Thor
    
    module Helpers
    
      def process_db_connect_params(db_name, db_user, db_password)
        params = Hash.new
        params[:db_name] = db_name||ask("Database Name? ") { |q| q.echo = true }	  
        params[:db_user] = db_user||ask("Database User? ") { |q| q.echo = true }
        params[:db_password] = db_password||ask("Database Password? ") { |q| q.echo = true }
        return params
      end

    end

    include Thor::Actions

    map "-v" => :version
    map "-h" => :help 
    map "-g" => :generate

    desc "version", "Currently installed version of Orasaurus."
    def version
      puts "Orasarus v"+Orasaurus::VERSION
    end
    

  
  end
=begin  
  class Generate < Thor::Group 
    argument :script_type, :type => :string, :desc => "Use build, teardown, or all."
    desc "generate scripts", "generate sqlplus scripts."   
    
    def generate(script_type)
      
      
      
      build_script_name = options[:build_script_name]||"build.sql"
      teardown_script_name = options[:teardown_script_name]||"teardown.sql"

      say "generating build scripts"
      s = Orasaurus.new( '.' )
      s.build_all_scripts( build_script_name, teardown_script_name )    
    end

    desc "generate_build_scripts", "generate sqlplus build scripts for the current directory."   
    method_options :build_script_name => :string, :teardown_script_name => :string 
    def teardown_scripts
      build_script_name = options[:build_script_name]||"build.sql"
      teardown_script_name = options[:teardown_script_name]||"teardown.sql"

      say "generating build scripts"
      s = Orasaurus::ScriptBuilder.new( '.' )
      s.build_all_scripts( build_script_name, teardown_script_name )    
    end
    
  end
=end

end