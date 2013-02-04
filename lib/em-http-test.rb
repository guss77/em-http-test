# EventMachine based HTTP load testing tool
#
# Author:: 		Oded Arbel (mailto:oded@heptagon.co.il)
# Copyright::	Copyright (c) 2013 Heptagon Software
# License::		GPL v3

require 'rubygems'
require 'eventmachine'
require 'em-http'
require 'fiber'

require 'em-http-test/definitions'
require 'em-http-test/test-failure'
require 'em-http-test/test-runner'
require 'em-http-test/load-test'
require 'em-http-test/test-request'

module EventMachine::HttpTest
	
	# run a load test by executing the test block multiple times in the
	# specified concurrency. The test will be executed for a total of runtime seconds
	def self.run(concurrency, runtime, &block)
		stats = { 
			:total => 0,
			:success => 0,
			:failure => 0,
			:failures => [],
		}
		
		successTimes = []
		
		if block.nil?
			stats[:error] = 'Invalid test block'
			return stats
		end
		
		startTime = Time.new
		
		EventMachine.run do
			test = LoadTest.new(concurrency) { block.call }
			test.onsuccess { |t| stats[:success] += 1; stats[:total] += 1; successTimes << t }
			test.onfailure { |t,e| stats[:failure] += 1; stats[:total] += 1; successTimes << t; stats[:failures] << e }
			EventMachine.add_periodic_timer(1) { puts "#{stats[:total]} tests run in #{(Time.new - startTime).to_i} seconds" }
			EventMachine.add_timer(runtime) { test.abort }
		end
		
		successTimes = successTimes.sort
		stats[:average] = (successTimes.reduce(:+).to_f / successTimes.size).round(2)
		stats[:percentile95] = (successTimes[(successTimes.count*0.95).to_i]).round(2)
		stats[:min] = (successTimes[0]).round(2)
		stats[:max] = (successTimes[-1]).round(2)
		stats[:failure_rate] = (stats[:failure].to_f / stats[:total]).round(2)
		
		return stats
	end

end
