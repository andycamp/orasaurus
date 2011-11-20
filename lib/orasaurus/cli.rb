require 'highline'
require 'thor'
require 'orasaurus/version'
require 'orasaurus/application'
    
module Orasaurus

  class CLI < Thor
    
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
        db_connect_options = process_db_connect_options(options.db_username, options.db_password, options,db_name)
        a.connect(db_connect_options[:db_username], db_connect_options[:db_password],db_connect_options[:db_name])
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
    
    def process_db_connect_options(db_username=nil, db_password=nil, db_name=nil)
       params = Hash.new
       params[:db_name] = db_name||ask("Database Name? ") { |q| q.echo = true }	  
       params[:db_username] = db_username||ask("Database User? ") { |q| q.echo = true }
       params[:db_password] = db_password||ask("Database Password? ") { |q| q.echo = "*" }
       return params
     end
   
  end

end