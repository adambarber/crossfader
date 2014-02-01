require 'thor'
require 'httmultiparty'
require 'crossfader/rcfile'
module Crossfader
	class CLI < Thor
		include HTTMultiParty
  		base_uri 'http://api.djz.com/v3'
		def initialize(*)
      		@rcfile = Crossfader::RCFile.instance
      		@loop_ids = []
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
			say "Let's convert wavs to MP3s!"
			dir = ask('Select a folder of loops to convert: ')
			dir = dir.gsub(/\\/, "").strip
			Dir.foreach(dir) { |file| convert_wav_to_mp3(file.to_s, dir.to_s) }
			say "The loops were converted successfully"
		end

		desc 'upload', 'Batch upload loops'
		def upload
			say "Time to upload some loops!"
			dir = ask('Select a folder of loops to upload: ')
			dir = dir.gsub(/\\/, "").strip
			Dir.foreach(dir) { |file| create_loop_from_file(file, dir) }
			say "The loops were uploaded successfully"
		end

		desc 'create_pack', 'Create a new pack'
		def create_pack
			say "Create a new pack? That's a great idea!"
			pack_name = ask "What should we call this pack?"
			pack_sub = ask "Enter the subtitle for this pack:"
			response = create_new_pack(pack_name, pack_sub)
			say response
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
			say "\`crossfader batch\` : Create a new pack, convert a folder of .wav files to .mp3 files and upload them to the server in one step.\n" 
			say "\`crossfader create_pack\` : Create a new empty pack.\n\n"
			say "---\n"
			say "Have questions, comments, or feed back? Contact Adam at adam@djz.com\n\n"
		end

		desc 'batch', "Create a new pack, convert wavs to mp3s, upload mp3s/jpgs as loops, and add loops to pack."
		def batch
			say "Time to batch convert and upload!"
			pack_name = ask "What do you want to name your new pack?"
			pack_sub = ask "Enter the subtitle for this pack:"
			dir = ask('Select a folder of loops to process and upload:')
			clean_dir = dir.gsub(/\\/, '').strip
			say clean_dir
			Dir.foreach(clean_dir) { |file| convert_wav_to_mp3(file.to_s, clean_dir.to_s) }
			Dir.foreach(clean_dir) { |file| create_loop_from_file(file.to_s, clean_dir.to_s) }
			response = create_new_pack(pack_name, pack_sub)
			if response.code == 200
				say "Success!"
			else
				say "Something went wrong."
			end
		end

		private

		def convert_wav_to_mp3(file, dir)
			file_path = File.join(dir, file)
			if File.file? file_path and File.extname(file_path) == ".wav"
				mp3_path = "#{file_path}.mp3".gsub!('.wav', '')
				mp3_path_low = "#{file_path}-low.mp3".gsub!('.wav', '')
				%x(lame -b 192 -h "#{file_path}" "#{mp3_path}")
				%x(lame -b 96 -m m -h "#{file_path}" "#{mp3_path_low}")
			end
		end

		def create_loop_from_file(file, dir)
			file_path = File.join(dir, file)
			if File.file? file_path and File.extname(file_path) == ".wav"
				loop_high = open(file_path.gsub('.wav', '.mp3'), 'r+b')
				loop_low = open(file_path.gsub('.wav', '-low.mp3'), 'r+b')
				artwork = open(file_path.gsub('.wav', '.jpg'), 'r+b')
				length, bpm, key, artist, title = file.to_s.gsub('.mp3', '').split(' - ')
				headers = { 'Authorization' => "Token: #{@rcfile.api_access_token}" }
				body = { title: title, type: 'loop', content: { artist_name: artist, bpm: bpm, key: key, bar_count: length, loop_type: "Instrumental Song" }, loop_high: loop_high, loop: loop_low, artwork: artwork, published: 'true' }
				options = { headers: headers , body: body }
				response = self.class.post('/feed_items', options)
				@loop_ids << response['id']
				say "New loop for #{title} created with an id of #{response['id']}"
			end
		end

		def create_new_pack(pack_name, pack_sub)
			headers = { 'Authorization' => "Token: #{@rcfile.api_access_token}" }
			body = { title: pack_name, content: { subtitle: pack_sub }, type: 'pack', pack_items: @loop_ids }
			options = { headers: headers , body: body }
			response = self.class.post('/feed_items', options)
			return response
		end
	end
end