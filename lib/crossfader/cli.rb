require 'thor'
require 'httmultiparty'
require 'crossfader/rcfile'
module Crossfader
	class CLI < Thor
		include HTTMultiParty
  		base_uri 'http://api.djz.com/v3'
		def initialize(*)
      		@rcfile = Crossfader::RCFile.instance
      		super
    	end

		desc 'auth', 'Allow the user to get their api access token'
		def auth
			say "Welcome! Before you can use crossfader, you'll first need to log in"
        	say 'to your account and get an access token. Follow the steps below:'
        	email = ask 'Enter your crossdfader.fm email address: '
        	password = ask('Enter your crossfader.fm password: ', :echo => false)
        	options = { :body => {email: email, password: password } }
    		response = self.class.post('/users/login', options)
    		if response.code == 200
	        	@rcfile[email] = { email: email, api_access_token: response['api_access_token'], dj_name: response['dj_name'] }
	        	say "\nAuthorized successfully!\n"
	        else
	        	say "\nSomething went wrong. Tell Adam.\n"
	        end
		end

		desc 'convert', 'Batch convert .wav files to .mp3 files'
		def convert
			loops = []
			say "Let's convert wavs to MP3s!"
			dir = ask('Select a folder of loops to convert: ')
			Dir.foreach(dir) do |file|
				file_path = File.join(dir, file)
				if File.file? file_path and File.extname(file_path) == ".wav"
					mp3_path = "#{file_path}.mp3".gsub!('.wav', '')
					system "lame -b 192 -h '#{file_path}' '#{mp3_path}'"
					loops << mp3_path.gsub("#{dir}/", '')
				end
			end	
			say "The following loops were converted successfully - #{loops.join(', ')}"
		end

		desc 'upload', 'Batch upload loops'
		def upload
			loops = []
			say "Time to upload some loops!"
			dir = ask('Select a folder of loops to upload: ')
			Dir.foreach(dir) do |file|
				file_path = File.join(dir, file)
				if File.file? file_path and File.extname(file_path) == ".mp3"
					loop_audio = open(file_path, 'r+b')
					artwork = open(file_path.gsub('.mp3', '.jpg'), 'r+b')
					length, bpm, key, artist, title = file.to_s.gsub('.mp3', '').split(' - ')
					headers = { 'Authorization' => "Token: #{@rcfile.api_access_token}" }
					body = { title: title, type: 'loop', content: { artist_name: artist, bpm: bpm, key: key, bar_count: length }, loop: loop_audio, artwork: artwork }
					options = { headers: headers , body: body }
					response = self.class.post('/feed_items', options)
					loops << title
				end
			end
			say "The following loops were uploaded successfully - #{loops.join(', ')}"
		end

		desc 'create_pack', 'Create a new pack'
		def create_pack
			say "Create a new pack? That's a great idea!"
			pack_name = ask "What should we call this pack?"
			pack_sub = ask "Enter the subtitle for this pack:"
			headers = { 'Authorization' => "Token: #{@rcfile.api_access_token}" }
			body = { title: pack_name, content: { subtitle: pack_sub }, type: 'pack' }
			options = { headers: headers , body: body }
			response = self.class.post('/feed_items', options)
			if response.code == 200
				say "Successfully created a pack named #{pack_name}"
			else
				say "Something went wrong."
			end
		end

		desc 'help', "Show available commands."
		def help
			say "\nYou can perform the following actions:"
			say "---\n\n"
			say "\`crossfader auth\` Authorize this app to work with the Crossfader.fm API.\n"
			say "\`crossfader convert\` : Convert a folder of .wav files to .mp3.\n"
			say "\`crossfader upload\` : Upload a folder of .mp3s to the server to create new loops.\n"
			say "\`crossfader batch\` : Convert a folder of .wav files to .mp3 files and upload them to the server in one step.\n" 
			say "\`crossfader create_pack\` : Create a new empty pack.\n\n"
			say "---\n"
			say "Have questions, comments, or feed back? Contact Adam at adam@djz.com\n\n"
		end
	end
end