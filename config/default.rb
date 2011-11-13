
Orasaurus.configure do |config|
  
  config.ignore_directories = %w(  )
  config.build_file_name = 'build.sql'
  config.build_log_file_name = 'build.log'
  config.teardown_file_name = 'teardown.sql'
  config.teardown_log_file_name = 'teardown.log'
  config.buildable_file_extensions = %w( .pkg .pks .pkb .sql .trg .prc. fnc .vw )
    
end 