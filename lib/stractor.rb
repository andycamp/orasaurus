require 'oci8'

class Stractor
  
  def initialize( db_user, db_password, db_name )
    
    @db_user = db_user
    @db_password = db_password
    @db_name = db_name
    
  end

  def extract_ddl( object_type, object_name )
  
    ddl_sql = %q{
SELECT dbms_metadata.get_ddl( :object_type, :object_name ) ddl_clob FROM dual
}
    
    db_connection = OCI8.new( @db_user, @db_password, @db_name )
    
    ddl = ""
    
    db_connection.exec( ddl_sql, object_type, object_name ) do |result|
      ddl << result[0].read
    end
    
    db_connection.logoff
    
    return ddl.delete( 34.chr ).gsub( Regexp.new( @db_user << '\.' ), '' ).strip << ";"
    
  end
  
  def extract_into_file( object_type, object_name, file_name )
  
    ddl = extract_ddl( object_type, object_name )
    File.open(file_name, 'w') {|f| f.write( ddl )}
  
  end
      
end

