$:.push File.expand_path("../lib", __FILE__)

require 'em-http-test/version'

Gem::Specification.new do |s|
	s.name        = "em-http-test"
	s.version     = EventMachine::HttpTest::VERSION
	
	s.platform    = Gem::Platform::RUBY
	s.authors     = ["Oded Arbel"]
	s.email       = ["oded@heptagon.co.il"]
	s.homepage    = "https://github.com/guss77/em-http-test"
	s.summary     = "EventMachine based, high performance web application load test framework"
	s.description = s.summary
	#s.rubyforge_project = "em-http-test"
	
	#s.add_dependency "eventmachine", ">= 0.12.0"
	s.add_dependency "em-http-request", ">= 0.3.0"
	
	#s.add_development_dependency "rake"
	
	s.files         = Dir['lib/**/*.rb'] + Dir['*.gemspec'] + Dir['*.md']
	#s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
	s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
	s.require_paths = ["lib"]
end
