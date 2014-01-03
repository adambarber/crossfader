require 'thor'

module Crossfader
	class CLI < Thor
		desc 'authorize', 'Allow the user to get their api access token'
		def authorize
			say "Welcome! Before you can use crossfader, you'll first need to log in"
        	say 'to your account and get an access token. Follow the steps below:'
        	email = ask 'Enter your crossdfader.fm email address: '
        	password = ask('Enter your crossfader.fm password: ', :echo => false)
		end
	end
end