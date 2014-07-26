#!/usr/bin/env ruby
require 'json'
require 'typhoeus'
require_relative 'response_checker'
require_relative 'data_generator'
require_relative 'data_fudger'
require_relative 'fudo'


if __FILE__ == $0

  commandlineinput = ARGV[0]

  full_request = JSON.parse(open(Fudo::CONFIG['root_dir'] + "/tests/" + Fudo::TEST_ROOT[commandlineinput]).read)

  y = Marshal.load(Marshal.dump(full_request['request']['body']))

  DataGenerator.generate_data(full_request['request']['body'])

  full_request['request']['bodysrc'] = y

  df = DataFudger.new(full_request)

  df.run


  request = Typhoeus::Request.new(
    full_request['request']['url'],
    method: full_request['request']['method'],
    body: full_request['request']['body'].to_json,
    verbose: false,
    headers: { 'Content-Type' => "application/json"}
  )

  request.run

  hydra = Typhoeus::Hydra.hydra

  outputjson = Array.new

  failures =
  df.fudged_data.each do | value |

    bad_reqs = Typhoeus::Request.new(
      value['request']['url'],
      method: value['request']['method'],
      body: value['request']['body'].to_json,
      verbose: false,
      headers: { 'Content-Type' => "application/json"}
    )
    bad_reqs.on_complete do | response |
      if (response.code != value['response']['status'])
        if(value['response']['status'].between?(400, 499) && response.code.between?(400,499))
          value['response']['severity'] -= 1
        elsif(value['response']['status'].between?(200, 299) && response.code.between?(200,299))
          value['response']['severity'] -= 1
        end
        outputjson << {"severity" => value['response']['severity'], "expected" => value['response']['status'],
                       "received" => response.code, "message" => value['response']['message'], "request" => value['request']}
      else
        outputjson << {"severity" => 100, "expected" => value['response']['status'],
                       "received" => response.code, "message" => value['response']['message'], "request" => value['request']}
      end
    end

    hydra.queue bad_reqs

  end

  hydra.run

  puts "Severity | Expected | Received | Message"

  outputjson.each do | value |

    puts "#{value['severity']}        | #{value['expected']}      | #{value['received']}        | #{value['message']}"

  end

end
