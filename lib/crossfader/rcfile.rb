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

	end
end