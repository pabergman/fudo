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

    puts JSON::Validator.validate(full_request['response']['body'], request.response.body)

  end

  def self.with_body(full_request)
    request = Typhoeus::Request.new(
      full_request['request']['url'],
      method: full_request['request']['method'],
      body: full_request['request']['body'].to_json,
      headers: full_request['request']['headers']
    )

    request.run

    puts JSON::Validator.validate(full_request['response']['body'], request.response.body)

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
        if (response.code != value['response']['status'])
          if(value['response']['status'].between?(400, 499) && response.code.between?(400,499))
            value['response']['severity'] += 1
          elsif(value['response']['status'].between?(200, 299) && response.code.between?(200,299))
            value['response']['severity'] += 1
          end
          unhappy_outout << {"severity" => value['response']['severity'], "expected" => value['response']['status'],
                             "received" => response.code, "message" => value['response']['message'], "request" => value['request']}
        elsif(Fudo::CONFIG['print_success'] == true)
          unhappy_outout << {"severity" => 100, "expected" => value['response']['status'],
                             "received" => response.code, "message" => value['response']['message'], "request" => value['request']}

        end

        if(response.code == 200)
          errors = JSON::Validator.fully_validate(value['response']['body'], response.body)
          # puts value['response']['message']
          puts errors
        elsif(response.code != 500 && Fudo::CONFIG['error_body'] == true)

          puts JSON::Validator.validate(value['response']['error_body'], response.body)

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

end
