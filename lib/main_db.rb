#ruby classes
require "oci8"
require "erb"
require "find"
require "logger"
  
#local classes
require "lib/DB_Table.rb"
require "lib/PLSQLGen.rb"

my_plsql_gen = PLSQLGen.new()  
params = my_plsql_gen.load_properties( "conf/PLSQLGen.conf" )

$system_column_names = ["CREATE_DATE", "CREATE_USER", "CREATE_PGM", "UPDATE_DATE", "UPDATE_USER", "UPDATE_PGM"]
$system_column_defaults = Hash.new
$system_column_defaults[ "CREATE_DATE" ] = "SYSDATE" 
$system_column_defaults[ "CREATE_USER" ] = "USER"
$system_column_defaults[ "CREATE_PGM" ] = "g_pkgName"
$system_column_defaults[ "UPDATE_DATE" ] = "SYSDATE"
$system_column_defaults[ "UPDATE_USER" ] = "USER"
$system_column_defaults[ "UPDATE_PGM" ] = "g_pkgName"

#oracle stuff 
conn = OCI8.new( params['db_user'], params['db_password'], params['db_name'])
tableList = Array.new
params['tables'].split( ',' ).each{ |s| tableList.push( conn.describe_table( s.strip ) ) }


pkg_names = Array.new()
app_abbr = params[ 'app_abbr' ]
app_name = params[ 'app_name' ]

logger = Logger.new( params[ 'log_path' ] + ".log", 'weekly')
logger.info('main') { "begin" }
puts "begin"

tableList.each { |tbl|

    logger.info('main') { "working with " + tbl.obj_name }
  
    $table = tbl
    $updatable_cols = Array.new
    tbl.columns.each{ |c| $updatable_cols.push( c ) unless $system_column_names.include?( c.name.upcase ) }
    #collect package name
    pkg_names.push( "pkg_" + $table.obj_name.downcase + params["pkg_name_suffix"] )
    #process spec
    begin
      my_plsql_gen.erb_to_file( my_plsql_gen.file_to_string( File.open( params[ 'spec_template' ], "r" )) \
        ,params[ 'destination_path' ] +   pkg_names.last + ".pkg")
      logger.info('main') { "creating spec " + pkg_names.last+".pkg" }
      puts "package created " + pkg_names.last+".pkg"
    rescue
      logger.error( 'main' ){"error processing spec for " + pkg_names.last }
      puts "There was a problem processing the spec for " + pkg_names.last
      puts $!
    end

=begin    
    #process body
    begin
      my_plsql_gen.erb_to_file(my_plsql_gen.file_to_string(File.open(params['body_template'],"r")) \
            ,params[ 'destination_path' ] + pkg_names.last+".pkb")
      logger.info('main') { "creating body " + pkg_names.last+".pkb" }              
      puts "creating body " + pkg_names.last+".pkb"              
    rescue
      logger.error( 'main' ){"error processing body for " + pkg_names.last }
      puts "There was a problem processing the body for " + pkg_names.last
      puts $!
    end      
    logger.info('main') { "package creation complete" }
=end  
}

=begin

#make home page
if params.has_key?('include_home') \
and params['include_home'] = 'YES' then
  #collect package name
  pkg_name.push("pkg_" + app_abbr.downcase + "_home")
  
  #making spec
  begin
    my_plsql_gen.erb_to_file( my_plsql_gen.file_to_string( File.open( params[ 'home_spec_template' ], "r" ) ) \
              , params[ 'destination_path' ] + pkg_name.last+".pks" )
    logger.info('main') { "creating spec " + pkg_name.last+".pks" }              
    puts "creating spec " + pkg_name.last+".pks"              
  rescue
    logger.error( 'main' ){"error processing body for " + pkg_name.last }
    puts "There was a problem processing the body for " + pkg_name.last
    puts $!
  end   
  
  #making body
  begin
    my_plsql_gen.erb_to_file( my_plsql_gen.file_to_string( File.open( params[ 'home_body_template' ], "r" ) ) \
              , params[ 'destination_path' ] + pkg_name.last+".pkb")                  
    logger.info('main') { "creating body " + pkg_name.last }              
    puts "creating body " + pkg_name.last
  rescue
    logger.error( 'main' ){"error processing body for " + pkg_name.last }
    puts "There was a problem processing the body for " + pkg_name.last
    puts $!
  end   
    
end
logger.info('main') { "home page create" }

#make db script
if params.has_key?('include_db_script') \
and params['include_db_script'] = 'YES' then
  role_name = params['role_name']
  begin
    #making grant script
    my_plsql_gen.erb_to_file( my_plsql_gen.file_to_string( File.open( params[ 'db_script_template' ], "r" ) ) \
                , params[ 'destination_path' ] + app_abbr.downcase + "_db_script.sql" )
    logger.info('main') { "db script created" }              
    puts "db script created "
  rescue
    logger.error( 'main' ){"error creating db script" + pkg_name.last }
    puts "There was a problem processing the db script"
    puts $!
  end         
end
=end
logger.info('main') { "end" }
logger.close
conn.logoff

puts "finished"  
