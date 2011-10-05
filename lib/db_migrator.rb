require "find"
require "fileutils"
require "highline/import"
require "oci8"

class DbMigrator
  
  @migration_directory
  @current_db_version
  @db_name
  @db_user
  @db_user_password
  
  def initialize( migration_directory, db_name, db_user, db_user_password )
    @migration_directory = migration_directory
    @db_name = db_name
    @db_user = db_user
    @db_user_password = db_user_password
    puts "Initializing database migrator"
    @current_db_version = get_current_db_version
  end
  
  def get_current_db_version
    current_version = 0
    begin
      conn = OCI8.new( $db_user, $db_user_password, $db_name )
      cursor = conn.exec( 'select value from tbparameters where system = \'FNS\' AND key = \'DB_VERSION\'' )
      current_version = cursor.fetch.first.to_i
      conn.logoff    
    rescue
      puts  "Error getting current db version from the database: #{ $! }"
      continue = ask( "The database version cannot be retrieved from the database. Would you like to continue?" ){ |q| q.echo = true }
      #if response begins with y
      if continue =~ /y/i then
        current_version = ask( "What is the current version number of the database (migrations that are greater than this number will be run)?", Integer ){ |q| q.echo = true }
      else
        puts "Exiting immediately. No database migrations will be run"
        exit
      end
    end
    return current_version
  end
  
  def set_db_version( version_no )
    begin
      conn = OCI8.new( $db_user, $db_user_password, $db_name )
      rows_updated = conn.exec( 'update tbparameters set value = :version_no where system = \'FNS\' AND key = \'DB_VERSION\'', version_no )
      if rows_updated == 1
        conn.commit
      else
        conn.rollback
        "#{ rows_updated } when 1 row was expected."
      end
      conn.logoff
      puts "new db_version set #{ version_no }"
    rescue
      puts "Error setting db version #{ $! }"
      puts "THE DATABASE WAS NOT UPDATED WITH THE LATEST VERSION NUMBER: #{ version_no }"
    end
  end
  
  def pluck_version_no( the_path )
    path_syllables = the_path.split( "_" )
    version_no = 0
    path_syllables.each do |syllable|
      #look for the first syllable that has no characters in it
      #the first integer syllable
      if not syllable =~ /\D/ then
        version_no = syllable.to_i
        break
      end
    end
    return version_no
  end
  
  def migratable_path?( the_path )
    if pluck_version_no( the_path ) > @current_db_version then
      return true
    else
      return false
    end
  end
  
  def migrate
    
    puts "beginning migration process..."
    puts @migration_directory
    puts "collecting files to migrate"
    migration_paths = Array.new
    Find.find(@migration_directory) do |path|
      if FileTest.file?(path) and path.match(/migration_\d.*sql/) and not path.match( /\.svn/ ) and migratable_path?(path)
        print "."
        migration_paths.push( path )
      end
    end
    #sort paths
    migration_paths = migration_paths.sort
    
    if migration_paths.length > 0 then
      migration_paths.each do |path|
        puts "sqlplus #{ $db_user }//#{ $db_user_password }@#{ $db_name } @#{ path }"
      end
      #capture last migration number
      final_db_version = pluck_version_no( migration_paths.last )
      puts "final db version #{ final_db_version }"
      #set database to version
      set_db_version( final_db_version )      
    else
      puts "database is current"
    end
    
  end
  
end

