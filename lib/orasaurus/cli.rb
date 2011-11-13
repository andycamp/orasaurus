require 'highline'

class Orasaurus

  module Cli
  
    def process_db_connect_params(db_name, db_user, db_password)
      params = Hash.new
      params[:db_name] = db_name||ask("Database Name? ") { |q| q.echo = true }	  
      params[:db_user] = db_user||ask("Database User? ") { |q| q.echo = true }
      params[:db_password] = db_password||ask("Database Password? ") { |q| q.echo = true }
      return params
    end
  
  end
    
end