
module Orasaurus
  
  class Configuration
  
    def initialize(data={})
      @data = {}      
      update!(data)
    end

    def update!(data)
      data.each do |key, value|
        self[key] = value
      end
    end

    def [](key)
      @data[key.to_sym]
    end

    def []=(key, value)
      if value.class == Hash
        @data[key.to_sym] = Configuration.new(value)
      else
        @data[key.to_sym] = value
      end
    end

    def method_missing(sym, *args)
      if sym.to_s =~ /(.+)=$/
        self[$1] = args.first
      else
        self[sym]
      end
    end
    
    def self.default
      config = Configuration.new
      config.ignore_directories = %w(  )
      config.build_file_name = 'build.sql'
      config.build_log_file_name = 'build.log'
      config.teardown_file_name = 'teardown.sql'
      config.teardown_log_file_name = 'teardown.log'
      config.buildable_file_extensions = %w( .pkg .pks .pkb .sql .trg .prc. fnc .vw )
      config.object_type_build_order = [:tables, :sequences, :types, :functions, :procedures, :packages, :triggers]
      return config
    end
        
  end
  
end