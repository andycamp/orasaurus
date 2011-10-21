#this is a build or make file written in ruby 
  
require "oci8"
require "fileutils"
require "highline/import"

$db_name = ""
$db_user = ""
$db_user_password = ""

def print_response
	if $? == 0 then 
		puts "completed successfully"
	else
		puts( "command failure" )
	end
end

def process_db_connect_params
	
	if ENV['db_user'].nil? then
	  $db_user = ask("Database User:  ") { |q| q.echo = true }	  
	else
		$db_user = ENV['db_user']
	end
	
	if ENV['db_user_password'].nil? then
	  $db_user_password = ask("Database User Password:  ") { |q| q.echo = "*" }	  
	else
		$db_user_password = ENV['db_user_password']
	end
	
	if ENV['db_name'].nil? then
		$db_name = ask("Database Instance:  ") { |q| q.echo = true }	  
	else
	  $db_name = ENV['db_name']	  
	end	
	
	if not $db_user.nil? and not $db_user_password.nil? and not $db_name.nil? then
	  return true
	else
	  puts "INVALID DATABASE CONNECTION PARAMETERS"
	end
	
end

def sqlplus_connect_string
	return $db_user + "/" + $db_user_password + "@" + $db_name
end

desc "Test database connection"
task :test_connection do
	if not process_db_connect_params then
		exit
		puts "test failed"
	else
	  puts "valid parameters"
	end	
	puts "Starting database connection test"
	begin
		conn = OCI8.new( $db_user, $db_user_password, $db_name )
		conn.logoff
		puts "Connection successful"
	rescue
		puts $!
		puts "Connection failed"
	end
end

desc "Rebuild all build and teardown scripts"
task :rebuild_build_scripts do
	if not process_db_connect_params then
		exit
	end
  
  s = ScriptBuilder.new( '.' )
  puts "building simple build scripts"
  s.build_all_scripts( 'build.sql', 'teardown.sql' )

  puts "re-doing table build scripts for proper order"
  t = TableScriptBuilder.new( $db_user, $db_user_password, $db_name, './Tables/' )
  puts 'build_tables has finished'
  
  puts 'done' 
end

=begin
desc "logs in as system and creates application schema user and issues all necessary grants"
task :do_grants do
	#check for args
	if not process_db_connect_params then
		exit
	end
	
	# call script
	sqlplus_cmd = "cd BuildScripts\\ && sqlplus " + $db_user + "/" + $db_user_password + "@" + $db_name + " @grants.sql"
	system "cd BuildScripts"
	system sqlplus_cmd
	system "cd .."
	#print response
	print_response
	
end
=end

desc "runs table build script"
task :build_tables do
	puts "building tables"
	if not process_db_connect_params then
		exit
	end	
	# call script
	sqlplus_cmd = "cd tables\\ && sqlplus " + $db_user + "/" + $db_user_password + "@" + $db_name + " @build.sql"
	system sqlplus_cmd
	print_response
end

desc "runs table teardown script"
task :teardown_tables do
	puts "teardown tables"
	if not process_db_connect_params then
		exit
	end	
	# call script
	sqlplus_cmd = "cd tables\\ && sqlplus " + $db_user + "/" + $db_user_password + "@" + $db_name + " @teardown.sql"
	system sqlplus_cmd
	print_response
end	

desc "runs table teardown, then table build script"
task :rebuild_tables => [:teardown_tables,:build_tables] do
	puts "rebuild complete"
end

desc "runs view build script"
task :build_views do
	puts "building views"
	if not process_db_connect_params then
		exit
	end	
	# call script
	sqlplus_cmd = "cd views\\ && sqlplus " + $db_user + "/" + $db_user_password + "@" + $db_name + " @build.sql"
	system sqlplus_cmd
	print_response
end

desc "runs view teardown script"
task :teardown_views do
	puts "teardown views"
	if not process_db_connect_params then
		exit
	end	
	# call script
	sqlplus_cmd = "cd views\\ && sqlplus " + $db_user + "/" + $db_user_password + "@" + $db_name + " @teardown.sql"
	system sqlplus_cmd
	print_response
end	

desc "runs view teardown, then view build script"
task :rebuild_views => [:teardown_views,:build_views] do
	puts "rebuild complete"
end

desc "runs sequence build script"
task :build_sequences do
	puts "building sequences"
	if not process_db_connect_params then
		exit
	end	
	# call script
	sqlplus_cmd = "cd bin\\ && sqlplus " + $db_user + "/" + $db_user_password + "@" + $db_name + " @rebuild_all_sequences.sql"
	puts sqlplus_cmd
	system sqlplus_cmd
	print_response	
end

desc "runs sequence teardown script"
task :teardown_sequences do
	puts "tearing down sequences"
	if not process_db_connect_params then
		exit
	end	
	# call script
	sqlplus_cmd = "cd sequences\\ && sqlplus " + $db_user + "/" + $db_user_password + "@" + $db_name + " @teardown.sql"
	system sqlplus_cmd
	print_response	
end

desc "runs sequence teardown then sequence build scripts"
task :rebuild_sequences => [:build_sequences] do
	puts "rebuild complete"	
end

desc "runs package model build script"
task :build_models do
	puts "building models"
	if not process_db_connect_params then
		exit
	end	
	# call script
	sqlplus_cmd = "cd packages\\models && sqlplus " + $db_user + "/" + $db_user_password + "@" + $db_name + " @build.sql"
	system sqlplus_cmd
	print_response	
end

desc "runs package model teardown script"
task :teardown_models do
	puts "tearing down models"
	if not process_db_connect_params then
		exit
	end	
	# call script
	sqlplus_cmd = "cd packages\\models && sqlplus " + $db_user + "/" + $db_user_password + "@" + $db_name + " @teardown.sql"
	system sqlplus_cmd
	print_response	
end

desc "runs package model teardown then build scripts"
task :rebuild_models => [:teardown_models, :build_models] do
	puts "rebuild complete"
end

desc "build controller packages"
task :build_controllers do
	puts "building controllers"
	if not process_db_connect_params then
		exit
	end	
	# call script
	sqlplus_cmd = "cd packages\\controllers && sqlplus " + $db_user + "/" + $db_user_password + "@" + $db_name + " @build.sql"
	system sqlplus_cmd
	print_response	
end

desc "teardown controller packages"
task :teardown_controllers do
	puts "tearing down controllers"
	if not process_db_connect_params then
		exit
	end	
	# call script
	sqlplus_cmd = "cd packages\\controllers && sqlplus " + $db_user + "/" + $db_user_password + "@" + $db_name + " @teardown.sql"
	system sqlplus_cmd
	print_response	
end

desc "teardown then rebuild all controllers"
task :rebuild_controllers => [:teardown_controllers, :build_controllers] do
	puts "rebuild complete"
end

desc "build helper packages"
task :build_helpers do
	puts "building helpers"
	if not process_db_connect_params then
		exit
	end	
	# call script
	sqlplus_cmd = "cd packages\\helpers && sqlplus " + $db_user + "/" + $db_user_password + "@" + $db_name + " @build.sql"
	system sqlplus_cmd
	print_response	
end

desc "teardown helper packages"
task :teardown_helpers do
	puts "tearing down helpers"
	if not process_db_connect_params then
		exit
	end	
	# call script
	sqlplus_cmd = "cd packages\\helpers && sqlplus " + $db_user + "/" + $db_user_password + "@" + $db_name + " @teardown.sql"
	system sqlplus_cmd
	print_response	
end

desc "teardown then build helper packages"
task :rebuild_helpers => [:teardown_helpers, :build_helpers] do
	puts "rebuild complete"
end

desc "build view packages"
task :build_pkg_views do
	puts "building views"
	if not process_db_connect_params then
		exit
	end	
	# call script
	sqlplus_cmd = "cd packages\\views && sqlplus " + $db_user + "/" + $db_user_password + "@" + $db_name + " @build.sql"
	system sqlplus_cmd
	print_response	
end

desc "teardown view packages"
task :teardown_pkg_views do
	puts "tearing down views"
	if not process_db_connect_params then
		exit
	end	
	# call script
	sqlplus_cmd = "cd packages\\views && sqlplus " + $db_user + "/" + $db_user_password + "@" + $db_name + " @teardown.sql"
	system sqlplus_cmd
	print_response	
end

desc "teardown then build view packages"
task :rebuild_pkg_views => [:teardown_pkg_views, :build_pkg_views] do
	puts "rebuild complete"
end

desc "teardown all packages"
task :teardown_packages => [:teardown_controllers, :teardown_views, :teardown_helpers, :teardown_models] do
	puts "teardown complete"
end

desc "build all packages"
task :build_packages => [:build_models, :build_helpers, :build_pkg_views, :build_controllers] do
	puts "package build complete"
end

desc "teardown and build all packages"
task :rebuild_packages => [:teardown_packages, :build_packages] do
	puts "rebuild complete"
end

desc "teardown the whole app...DANGEROUS!!!! BE CAREFUL RUNNING THIS ONE"
task :teardown_app => [:teardown_packages, :teardown_views, :teardown_sequences, :teardown_tables] do
	puts "application teardown complete"
end

desc "builds the application from the ground up"
task :build_app => [:build_tables, :build_sequences, :build_views, :build_packages] do
	puts "application build complete"
end

desc "teardown the rebuild the appliction from the ground up...DANGEROUS!!! you will lose all data if you run this script"
task :rebuild_app => [:teardown_app, :build_app] do
	puts "application rebuild complete"
	puts Time.now.to_s
end

desc "teardown the rebuild the appliction from the ground up...DANGEROUS!!! you will lose all data if you run this script"
task :rebuild_app => [:teardown_app, :build_app] do
	puts "application rebuild complete"
	puts Time.now.to_s
end
	
desc "run database migrations"
task :run_db_migrations do
  puts "running database migrations"
  if not process_db_connect_params then
		exit
	end
  mig = DbMigrator.new( "Migrations", $db_name, $db_user, $db_user_password )
  mig.migrate
  puts "done runing database migrations"
end

desc "runs trigger build script"
task :build_triggers do
	puts "building triggers"
	if not process_db_connect_params then
		exit
	end	
	# call script
	sqlplus_cmd = "cd triggers\\ && sqlplus " + $db_user + "/" + $db_user_password + "@" + $db_name + " @build.sql"
	system sqlplus_cmd
	print_response
end

desc "lines of code"
task :lines_of_code do
  puts "Generating lines of code report"
  system "cd bin && lines_of_code.rb"
end

