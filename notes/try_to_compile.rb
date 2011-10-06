require 'oci8'


f2k = OCI8.new("junk", "password", "xe")

puts "effin' eh"

pkg = File.open( 'pkg_fdr_bridges.pks' )    

#f = f2k.exec( "#{ pkg.read }; " )  

#puts f.to_s

#puts f2k.exec( "SHOW  ERRORS" )

 error_cursor = f2k.exec( "SELECT * FROM USER_ERRORS" ) 

 while r = error_cursor.fetch_hash()
   puts r.to_s
 end

# errors = .fetch_hash() 

puts errors.to_s

puts "done"

f2k.logoff