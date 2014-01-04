require 'singleton'

module Crossfader
	class RCFile
		include Singleton
		attr_reader :path
		FILE_NAME = '.crossfader'

		def initialize
      		@path = File.join(File.expand_path('~'), FILE_NAME)
      		@data = load_file
    	end

    	def load_file
      		require 'yaml'
      		YAML.load_file(@path)
    	rescue Errno::ENOENT
      		default_structure
    	end

    	def []=(email, profile)
      		configuration['email'] = profile[:email]
      		configuration['api_access_token'] = profile[:api_access_token]
      		configuration['dj_name'] = profile[:dj_name]
    		write
    	end

    	def configuration
      		@data['configuration']
    	end

    	def api_access_token
    		@data['configuration']['api_access_token']
    	end

    	private

    	def default_structure
      		{'configuration' => {}}
    	end

    	def write
      		require 'yaml'
      		File.open(@path, File::RDWR | File::TRUNC | File::CREAT, 0600) do |rcfile|
        		rcfile.write @data.to_yaml
      		end
    	end

	end
end