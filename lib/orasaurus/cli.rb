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

    desc "generate [SCRIPT_TYPE]", "Generate scripts. SCRIPT_TYPE is optional. Valid values are build_scripts, teardown_scripts and all." 
    method_option :base_dir, :type => :string, :default => ".", :desc => "Base Directory for your code. Defaults to your current location.", :optional => true
    method_option :sort_method, :type => :string, :default => :none, :desc => "The method used for ordering the scripts. The only available option other than the default is SQL, which will order the scripts by dependency in the database (assuming the file name is a database object name.", :optional => true
    method_option :db_name, :type => :string, :desc => "Only needed if order_method is sql.", :optional => true
    method_option :db_username, :type => :string, :desc => "Only needed if order_method is sql.", :optional => true
    method_option :db_password, :type => :string, :desc => "Only needed if order_method is sql.", :optional => true
    def generate(script_type=:all)
      puts "generate " + script_type.to_s + " #{options.to_s}"
      a = Orasaurus::Application.new("cli",options.base_dir)
      
      if options.sort_method.upcase == "SQL" then
        puts "connecting for sql sorting."
        a.connect(options.db_username, options.db_password,options.db_name)
        sort_options = { :method => :SQL, :db_connection => a.connection }
      else
        sort_options = {}  
      end
      
      if [:build_scripts,:all].include? script_type.to_sym then
        puts "generating build scrtipts"
        a.generate(:build_scripts, sort_options)
      end
      
      if [:teardown_scripts,:all].include? script_type.to_sym then
        puts "generating teardown scripts"
        a.generate(:teardown_scripts, sort_options)
      end
      
    end

    desc "version", "Currently running version of Orasaurus."
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