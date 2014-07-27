#!/usr/bin/env ruby
require 'json'
require 'typhoeus'
require 'json-schema'
require_relative 'data_generator'
require_relative 'data_fudger'


class RunTest

  def self.run(full_request)

    body_def = Marshal.load(Marshal.dump(full_request['request']['body']))
    DataGenerator.generate_data(full_request['request']['body'])
    full_request['request']['bodysrc'] = body_def

    if(full_request['request']['method'] == "GET" || full_request['request']['method'] == "DELETE")
      request = no_body(full_request)

    else

      data_fudger = DataFudger.new(full_request)
      data_fudger.run

      with_body(full_request)
      run_unhappy(data_fudger.fudged_data)

    end

  end

  def self.no_body(full_request)
    request = Typhoeus::Request.new(
      full_request['request']['url'],
      method: full_request['request']['method'],
      headers: full_request['request']['headers']
    )

    request.run

  end

  def self.with_body(full_request)
    request = Typhoeus::Request.new(
      full_request['request']['url'],
      method: full_request['request']['method'],
      body: full_request['request']['body'].to_json,
      headers: full_request['request']['headers']
    )

    request.run

  end

  def self.run_unhappy(fudged_data)
    unhappy_outout = Array.new
    hydra = Typhoeus::Hydra.new

    fudged_data.each do | value |

      bad_request = Typhoeus::Request.new(
        value['request']['url'],
        method: value['request']['method'],
        body: value['request']['body'].to_json,
        verbose: false,
        headers: value['request']['headers']
      )
      bad_request.on_complete do | response |

        error_message = logging(response,value)
        if(error_message['severity'] < 100 || Fudo::CONFIG['log_success'] == true)
          unhappy_outout << error_message
        end
      end

      hydra.queue bad_request

    end
    hydra.run

    puts unhappy_outout.to_json

    puts "Severity | Expected | Received | Message"

    unhappy_outout.each do | value |

      print value['severity'].to_s.ljust(9)
      print "| #{value['expected']}".ljust(11)
      print "| #{value['received']}".ljust(11)
      puts "| #{value['message']}"

    end
  end

  def self.logging(response, value)


    error_message = {}

    if (response.code != value['response']['status'])
      if(value['response']['status'].between?(400, 499) && response.code.between?(400,499))
        value['response']['severity'] += 2
      elsif(value['response']['status'].between?(200, 299) && response.code.between?(200,299))
        value['response']['severity'] += 1
      end
      error_message = {"severity" => value['response']['severity'], "expected" => value['response']['status'],
                       "received" => response.code, "message" => value['response']['message'], "request" => value['request']}
    else
      error_message = {"severity" => 100, "expected" => value['response']['status'],
                       "received" => response.code, "message" => value['response']['message'], "request" => value['request']}
    end

    if(response.code == 200)
      errors = JSON::Validator.fully_validate(value['response']['body'], response.body)
      if(errors.size > 0)
        error_message['validation_errors'] = errors
        error_message['response_body'] = response.body
        error_message['severity'] = 1;
      end
    end

    if(response.code.between?(400,499) && Fudo::CONFIG['validate_errors'] == true)
      errors = JSON::Validator.fully_validate(value['response']['error_body'], response.body)
      error_message['validation_errors'] = errors
      error_message['response_body'] = response.body
    end

    error_message

  end

end
