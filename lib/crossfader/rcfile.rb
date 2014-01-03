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
    		write
    	end

    	private

    	def default_structure
      		{'configuration' => {}, 'profiles' => {}}
    	end

    	def write
      		require 'yaml'
      		File.open(@path, File::RDWR | File::TRUNC | File::CREAT, 0600) do |rcfile|
        		rcfile.write @data.to_yaml
      		end
    	end

	end
end