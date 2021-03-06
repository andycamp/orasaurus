require 'orasaurus/configuration'
require 'orasaurus/generator'
require 'orasaurus/db'

module Orasaurus
  
  class Application
    
    include Orasaurus::DB
    
    attr_accessor :config,:name,:base_dir, :build_dirs, :connection
    
    @connection = Object.new
    
    def initialize(name,base_dir)
      @name = name
      if File.directory? base_dir 
        @base_dir = base_dir 
      else 
        raise "Directory not found."
      end
      @config = Orasaurus::Configuration.default
      @build_dirs = fill_build_dirs
      puts "Orasaurus has been awakened."
      puts "Build Dirs: #{@build_dirs.to_s}"
    end

    #Connects to the database. Use oci8 args to connect
    def connect(*args)
      @connection = Connection.new(*args)
    end

    def ignore_filenames
      files = %w{ @config.build_file_name @config.build_log_file_name @config.teardown_file_name @config.teardown_log_file_name }
    end
  
    def generate(type,sortOpts={})
      if [:build_scripts,:teardown_scripts].include? type.to_sym 
        puts "generating #{type}"
        generate_scripts(type,sortOpts)
      else
        puts "Don't know how to generate " + type.to_s
      end
    end

    def get_build_items(dir,sortOpts={})
      buildable_items = Array.new
      search_list = Dir.glob(dir + "/*.*" )
      search_list.each do |f|
        #TODO refactor to regex
        if File.file?( f ) \
        and not ignore_filenames.include?(File.basename(f)) \
        and @config.buildable_file_extensions.include?(File.extname(f)) \
        then
          buildable_items.push(File.basename(f))
        end		
      end
      puts "#{dir} build_items: #{buildable_items.to_s}"
      sortOpts[:db_connection] = @connection
      return Builder.sort(buildable_items,sortOpts)
    end
  
    def generate_scripts(type,sortOpts={})
      if @build_dirs.length > 0 then
        @build_dirs.each do |dir|
          case type
          when :build_scripts
            Orasaurus::SqlBuildGenerator.new(dir,dir,config.build_file_name,get_build_items(dir,sortOpts)).generate
          when :teardown_scripts
            Orasaurus::SqlTeardownGenerator.new(dir,dir,config.teardown_file_name,get_build_items(dir,sortOpts)).generate
          end
        end
      else 
        puts "nothing found to work on."
      end
    end

    protected

    def fill_build_dirs
      buildable_dirs = Array.new
      Find.find(@base_dir) do |f|
        if File.directory?(f) 
          buildable_dirs.push(f) unless @config.ignore_directories.include?(f.split("/").pop)
        end
      end
      return buildable_dirs
    end
    
  end

end