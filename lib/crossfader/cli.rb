require 'thor'
require 'rake'
require 'rake/clean'
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
			say "Let's convert wavs to MP3s!"
			dir = ask('Select a folder of loops to convert: ')
			files = FileList.new("#{dir}/*.wav")
			files.each{|file| convert_wav_to_mp3(file) }
			say "The loops were converted successfully"
		end

		desc 'upload', 'Batch upload loops'
		def upload
			say "Time to upload some loops!"
			dir = ask('Select a folder of loops to upload: ')
			wavs = FileList["#{dir}/*.wav"]
			wavs.each{|file| create_loop_from_file(file) }
			say "The loops were uploaded successfully"
		end

		desc 'create_pack', 'Create a new pack'
		def create_pack
			say "Create a new pack? That's a great idea!"
			pack_name = ask "What should we call this pack?"
			pack_sub = ask "Enter the subtitle for this pack:"
			response = create_new_pack(pack_name, pack_sub)
			say response.code
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
			say "\`crossfader clean\` : Remove all MP3s from a folder.\n\n"
			say "---\n"
			say "Have questions, comments, or feed back? Contact Adam at adam@djz.com\n\n"
		end

		desc 'batch', "Create a new pack, convert wavs to mp3s, upload mp3s/jpgs as loops, and add loops to pack."
		def batch
			say "Time to batch convert and upload!"
			pack_name = ask "What do you want to name your new pack?"
			pack_sub = ask "Enter the subtitle for this pack:"
			dir = ask('Select a folder of loops to process and upload:')
			files = FileList.new("#{dir}/*.wav")
			files.each{|file| convert_wav_to_mp3(file) }
			loop_responses = files.map{|file| create_loop_from_file(file) }
			loop_ids = loop_responses.map{|r| r['id'] }
			response = create_new_pack(pack_name, pack_sub, loop_ids)
			if response.code == 200
				say "Success!"
			else
				say "Something went wrong."
			end
		end

		desc 'clean', "Remove all MP3s from a folder."
		def clean
			dir = ask('Select a folder of MP3s to delete: ')
			mp3s = FileList["#{dir}/*.mp3"]
			Rake::Cleaner.cleanup_files(mp3s)
			say "Removed MP3s successfully."
		end

		private

		def convert_wav_to_mp3(file)
			mp3 = file.ext(".mp3")
			mp3_low = "#{file.ext}-low.mp3"
			%x(lame -b 192 -h "#{file}" "#{mp3}")
			%x(lame -b 96 -m m -h "#{file}" "#{mp3_low}")
		end

		def create_loop_from_file(file)
			mp3 = File.open(file.ext(".mp3"), 'r+b')
			mp3_low = File.open("#{file.ext}-low.mp3", 'r+b')
			artwork = File.open(file.ext('.jpg'), 'r+b')
			length, bpm, key, artist, title = file.ext.split("-").map(&:strip)
			headers = { 'Authorization' => "Token: #{@rcfile.api_access_token}" }
			body = { title: title, type: 'loop', content: { artist_name: artist, bpm: bpm, key: key, bar_count: length, loop_type: "Instrumental Song" }, loop: mp3, loop_low: mp3_low, artwork: artwork, published: 'true' }
			options = { headers: headers , body: body }
			response = self.class.post('/feed_items', options)
			say "Uploaded #{title} successfully with an id of #{response['id']}."
			response
		end

		def create_new_pack(pack_name, pack_sub, loop_ids)
			headers = { 'Authorization' => "Token: #{@rcfile.api_access_token}" }
			body = { title: pack_name, content: { subtitle: pack_sub }, type: 'pack', pack_items: loop_ids }
			options = { headers: headers , body: body }
			response = self.class.post('/feed_items', options)
			return response
		end
	end
end