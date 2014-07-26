#!/usr/bin/env ruby
require 'json'


class FudoJsonGenerator

  def self.master(input, output)

    if input.is_a? Array
      array(input,output)
    elsif input.is_a? Hash
      hash(input,output)
    else
      value(input,output)
    end

  end

  def self.array(input, output)

    output['type'] = "array"
    output['rules'] = Hash.new
    output['rules']['min'] = 0
    output['rules']['max'] = input.length * 2
    output['rules']['repeat'] = false
    output['properties'] = Hash.new

    input.each_with_index do |value, index|

      output['properties'][index] = Hash.new

      master(value, output['properties'][index])

    end

  end

  def self.hash(input, output)

    output['type'] = "object"

    output['rules'] = Hash.new

    output['rules']['required'] = true

    output['properties'] = Hash.new
    input.each do |key, value|
      output['properties'][key] = Hash.new
      master(value, output['properties'][key])
    end
  end

  def self.value(input, output)
    output['type'] = "value"
    output['rules'] = Hash.new
    output['rules']['value-type'] = input.class.to_s
    output['rules']['donotmodify'] = false
    output['rules']['required'] = true
    output['rules']['unique'] = false

    output['properties'] = Hash.new
    output['properties']['source'] = "fixed"
    output['properties']['value'] = input
    output['inputs'] = Array.new
  end

end

if __FILE__ == $0

  puts "What method? (POST, PUT, GET, DELETE)"
  method = gets.chomp
  puts "What URL?"
  url = gets.chomp

  if(method == "POST" || method == "PUT")
    puts "Request body JSON please."
    input = JSON.parse(gets.chomp)
    request_body = JSON.parse("{}")
    FudoJsonGenerator.master(input, request_body)
  else
    request_body = JSON.parse("{}")
  end

  puts "Response body JSON please."
  response_body = JSON.parse(gets.chomp)


  fudo_request = {"request" => {"method" => method, "url" => url, "headers" => {}, "body" => request_body},
                  "response" => {"body" => response_body, "headers" => {}, "status" => 200, "message" => "should pass"}}

  # shittystring = '[{"status": "new", "name": "alex", "id": 10},{"status": "new", "name": "alex", "id": 11}]'
  # shittystring = '{"status": "new", "name": "alex", "id": {"status": "new", "name": [2,3,4,5]}}'
  # shittystring = '{"status": "new", "name": "alex", "id": {"status": "new"}}'

  puts JSON.pretty_generate(fudo_request)

end
