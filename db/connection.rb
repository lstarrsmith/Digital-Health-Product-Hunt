require 'active_record'

# # if ENV["DB_INFO"]
# 	ActiveRecord::Base.establish_connection('postgresql://' + ENV["DB_INFO"] + '@127.0.0.1/forum')

# else
	ActiveRecord::Base.establish_connection({
	  :adapter => "postgresql",
	  :host => "localhost",
	  :username => "Logan",
	  :database => "forum"
	  })

  ActiveRecord::Base.logger = Logger.new(STDOUT)