#!/usr/bin/env ruby
require 'json'
require 'typhoeus'
require_relative 'data_generator'
require_relative 'data_fudger'


class RunTest

  def self.run(full_request)
    if(full_request['request']['method'] == "GET" || full_request['request']['method'] == "GET")
      request = no_body(full_request)
    else
      with_body(full_request)
      fudged_data = create_unhappy(full_request)
      run_unhappy(fudged_data)
    end

  end

  def self.no_body(full_request)
    request = Typhoeus::Request.new(
      full_request['request']['url'],
      method: full_request['request']['method'],
      verbose: false,
      headers: full_request['request']['headers']
    )

    request.run

  end

  def self.with_body(full_request)
    request = Typhoeus::Request.new(
      full_request['request']['url'],
      method: full_request['request']['method'],
      body: full_request['request']['body'].to_json,
      verbose: false,
      headers: full_request['request']['headers']
    )

    request.run

  end

  def self.create_unhappy(full_request)

    body_def = Marshal.load(Marshal.dump(full_request['request']['body']))
    DataGenerator.generate_data(full_request['request']['body'])
    full_request['request']['bodysrc'] = body_def

    data_fudger = DataFudger.new(full_request)
    data_fudger.run

    data_fudger.fudged_data
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
        headers: { 'Content-Type' => "application/json"}
      )
      bad_request.on_complete do | response |
        if (response.code != value['response']['status'])
          if(value['response']['status'].between?(400, 499) && response.code.between?(400,499))
            value['response']['severity'] -= 1
          elsif(value['response']['status'].between?(200, 299) && response.code.between?(200,299))
            value['response']['severity'] -= 1
          end
          unhappy_outout << {"severity" => value['response']['severity'], "expected" => value['response']['status'],
                             "received" => response.code, "message" => value['response']['message'], "request" => value['request']}
        else
          unhappy_outout << {"severity" => 100, "expected" => value['response']['status'],
                             "received" => response.code, "message" => value['response']['message'], "request" => value['request']}
        end
      end

      hydra.queue bad_request

    end

    hydra.run

    puts "Severity | Expected | Received | Message"

    unhappy_outout.each do | value |

      puts "#{value['severity']}        | #{value['expected']}      | #{value['received']}        | #{value['message']}"

    end
  end
end


if __FILE__ == $0

  commandlineinput = ARGV[0]

  full_request = JSON.parse(open(Fudo::CONFIG['root_dir'] + "/tests/" + Fudo::TEST_ROOT[commandlineinput]).read)

  RunTest.run(full_request)

end
