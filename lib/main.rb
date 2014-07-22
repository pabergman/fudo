#!/usr/bin/env ruby
require 'json'
require 'typhoeus'
require 'vine'
require_relative 'response_checker'
require_relative 'data_generator'
require_relative 'data_fudger'
require_relative 'fudo'


if __FILE__ == $0



  commandlineinput = "uniqueness/oneunique"

  full_request = JSON.parse(open(Fudo::CONFIG.access('root_dir') + "tests/" + commandlineinput + ".json").read)

  y = Marshal.load(Marshal.dump(full_request['request']['body']))

  DataGenerator.generate_data(full_request['request']['body'])

  full_request['request']['bodysrc'] = y

  df = DataFudger.new(full_request)

  df.run

  puts JSON.pretty_generate(df.fudged_data)

  request = Typhoeus::Request.new(
    full_request['request']['url'],
    method: full_request['request']['method'],
    body: full_request['request']['body'].to_json,
    verbose: false,
    headers: { 'Content-Type' => "application/json"}
  )

  request.run

  hydra = Typhoeus::Hydra.hydra

  bad_reqs = Array.new

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
        puts "FAILURE: Expected status code #{value['response']['status']} but got #{response.code}, message is: #{value['response']['message']}"
      else
        puts "SUCCESS: Expected status code #{value['response']['status']} and got #{response.code}, message is: #{value['response']['message']}"
      end
    end

    hydra.queue bad_reqs

  end

  hydra.run

end
