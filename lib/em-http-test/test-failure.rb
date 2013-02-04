# EventMachine based HTTP load testing tool
#
# Author:: 		Oded Arbel (mailto:oded@heptagon.co.il)
# Copyright::	Copyright (c) 2013 Heptagon Software
# License::		GPL v3

module EventMachine::HttpTest
	
	# Exception to raise in test code to signify a test failure
	class TestFailure < Exception
	
		attr_accessor :message
		
		def initialize(text)
			self.message = text;
		end
		
	end
	
end
