em-http-test
============

Ruby EventMachine-base HTTP load testing library that allows writing simple web application testing scenarios
that are run using high performance asynchronous IO powered by EventMachine and em-http-request.

Requirements are EventMachine, em-http-request and fiber.

Usage is very simple, for example:

    #!/usr/bin/ruby

    require 'em-http-test'

    concurrency = 10000
    runtime = 300

    EM::HttpTest::run(concurrency, runtime) do
        response = EM::HttpTest::post('http://mytestapp/login', :query => { 'username' => 'oded', 'password' => '123' }
        sessionid = response['PHPSESSIONID'])
        raise EM::HttpTest::TestFailure, "Error in login" unless response.response_header.status == 200
        response = EM::HttpTest::get('http://mytestapp/list', :query => { 'filter' => 'all' },
            :head => { 'PHPSESSIONID' => sessionid })
        raise EM::HttpTest::TestFailure, "Error in list" unless response.response_header.status == 200
    end

The block passed to `run()` will be executed continously for 300 seconds, with 10,000 sessions running simoultaneously.
The `EventMachine::HttpTest::post` and `EventMachine::HttpTest::get` are used to dispatch the HTTP requests in an
apparently synchronous manner allowing test sessions to be written using a simple programming model. 

The named arguments passed to `post()` and `get()` are passed to em-http-request and any arguments supported by 
em-http-request can be used. To facilitate ease of use, `HttpTest` will convert `:query` data to `:body` content
when using `post()`. The return value for `post()` and `get()` is the em-http-request client with the response
data, which can be examined according to the em-http-request API.

To abort a testing session without aborting the entire load test, raise `EventMachine::HttpTest::TestFailure`. All such
errors will be collected, the aborted session will be counted as a test failure and the exception data will be available
in the test results summary.

The return value from `run()` is a hash with the following fields:

* `:total`       - total number of sessions that were run
* `:success`      - total number of sessions that completed without raising a TestFailure
* `:failure`      - total number of sessions that raised a TestFailure
* `:failures`     - array containing the exception data element for each failed session
* `:failure_rate` - the rate of session failures compared to completed sessions (0 to 1)
* `:min`          - the number of seconds that the fastest session completed in
* `:max`          - the number of seconds that the slowest session completed in
* `:average`      - average number of seconds for all test sessions (including failures)
* `:percentile95` - 95% of the sessions completed in this number of seconds or less

Results in seconds could be fractional seconds.
