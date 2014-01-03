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

    	private

    	def default_structure
      		{'configuration' => {}, 'profiles' => {}}
    	end

	end
end