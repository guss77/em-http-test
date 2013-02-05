# EventMachine based HTTP load testing tool
#
# Author:: 		Oded Arbel (mailto:oded@heptagon.co.il)
# Copyright::	Copyright (c) 2013 Heptagon Software
# License::		GPL v3

# Run a single HTTP test by iterating through the test operatins until the test
# either raises TestFailure or completes successfully
module EventMachine::HttpTest
	
	class TestRunner
		include EM::Deferrable
		
		def initialize(f)
			@fiber = f
			@testreq = @fiber.resume # first call, so no data to test
			@running = true
			process
		end
		
		def abort
			@running = false
		end
		
		# Run a step of the test by calling the test generated URL
		# and submitting the results to be processed
		def process
			unless @fiber.alive? and @running
				# if the fiber has completed, then we succeeded
				self.succeed()
				return
			end
			
			# do another run
			request = @testreq.toRequest
			request.errback { |r| self.handleResponse(r) }
			request.callback { |r| self.handleResponse(r) }
		end
		
		def handleResponse(r)
			if r.response_header.status >= 400
				self.fail("HTTP error #{r.response_header.status} calling #{r.last_effective_url}")
				return
			end
			
			begin
				@testreq = @fiber.resume r
				case when @testreq.nil?
					self.succeed("Test is done")
				else
					self.process
				end
			rescue TestFailure => e
				self.fail(e.message)
			end
		end
		
	end

end
