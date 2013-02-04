# EventMachine based HTTP load testing tool
#
# Author:: 		Oded Arbel (mailto:oded@heptagon.co.il)
# Copyright::	Copyright (c) 2013 Heptagon Software
# License::		GPL v3

module EventMachine::HttpTest
	
	# Run the specified test in the specified concurrency
	class LoadTest
		include EM::Deferrable
		
		def initialize(concurrency, &block)
			@concurrency = concurrency
			@runners = [] # list of currently running tests
			@failureCB = [] # list of failure callbacks
			@successCB = [] # list of success callbacks
			@test = block
			@running = true
			
			@concurrency.times { self.startTest }
		end

		# stop the test and don't execute any more test runners
		def abort
			@running = false
		end

		# register a failure handler
		def onfailure(&block)
			@failureCB << block
		end

		# register a success handler
		def onsuccess(&block)
			@successCB << block
		end
		
		def count
			return @runners.size
		end

		# Add a new test runner
		def startTest
			return unless @running # don't start new tests if the EventMachine is stopping
			startAt = Time.new
			# create a new runner and add it to the queue
			runner = TestRunner.new(Fiber.new { @test.call })
			@runners << runner
			runner.errback do |e| # if the runner failed
				@runners.delete(runner) # remove it from the queue
				@failureCB.each { |b| b.call(Time.new - startAt, e) } # notify the failure handler
				self.tick # then tick the load test
			end
			runner.callback do # if the runnner completed
				@runners.delete(runner) # remove it from the queue
				@successCB.each { |b| b.call(Time.new - startAt) } # notify the success handler
				self.tick # then tick the load test
			end
		end

		# Replenish test runners
		def tick
			if !@running and @runners.count < 1
				EM.stop
				return
			end
			missing = @concurrency - @runners.count
			missing.times { self.startTest }
		end

	end

end
