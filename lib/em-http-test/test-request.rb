# EventMachine based HTTP load testing tool
#
# Author:: 		Oded Arbel (mailto:oded@heptagon.co.il)
# Copyright::	Copyright (c) 2013 Heptagon Software
# License::		GPL v3

module EventMachine::HttpTest
	
	# Base test request object that contains the test data
	class Request
		@@reqOptions = {
			:connect_timeout => 5,        # default connection setup timeout
			:inactivity_timeout => 30,    # default connection inactivity (post-setup) timeout
		}
		
		def self.option(opts = {})
			opts.each { |k,v| @@reqOptions[k] =v }
		end
	
		def initialize(type, url, options = {})
			@type = type
			@url = url
			@options = options
			if @type == :POST and !@options[:query].nil?
				@options[:body] = @options[:query]
				@options.delete(:query)
			end
		end
		
		def toRequest
			case @type
			when :GET
				EM::HttpRequest.new(@url, @@reqOptions).get @options
			when :POST
				EM::HttpRequest.new(@url, @@reqOptions).post @options
			end
		end
	end

	# do a evented HTTP GET
	def self.get(url, options = {})
		Fiber.yield Request.new(:GET, url, options)
	end

	# do a evented HTTP POST
	def self.post(url, options = {})
		Fiber.yield Request.new(:POST, url, options)
	end

end
