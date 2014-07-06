#!/usr/bin/env ruby
require 'json'
require 'typhoeus'
require 'ffaker'
require 'active_support/all'
require 'vine'
require_relative 'response_checker'
require_relative 'fudo'


class RequestCreator

  def self.create_request(request)

  end

  def self.generate_enviroment(environment)
    environment.each do |key, value|
      case value['type']
      when 'string' then environment[key] = set_value(value['properties'])
      when 'object' then environment[key] = generate_enviroment(value['properties'])
      end
    end

  end

  def self.set_value(properties)

    case properties['source']
    when 'ffaker' then value = "Faker::#{properties['value']['class']}".constantize.send(properties['value']['method'], *properties['inputs'])
    when 'global' then value = Fudo::GLOBAL_VARIABLES.access(properties['value'])
    when 'fixed' then value = properties['value']
    when 'runtest' then #do stuff
    when 'previoustest' then #do stuff
    when 'custom' then #dostuff
    when 'environmental' then #dostuff
    else puts "#{properties['source']} is not supported."
    end
    return value

  end

  def self.fake_value(value, inputs)
    "Faker::#{b}".constantize.send(x, *c)
  end

  def self.generate_inputs()

  end

end

if __FILE__ == $0

  stuff = '{
    "name": {
      "type": "string",
      "properties": {
        "source": "ffaker",
        "value": { "class": "Internet", "method": "user_name"},
        "inputs": ["Alexander Bergman"]
      }
    },
    "name-2": {
      "type": "object",
      "properties": {
        "surname": {
          "type": "string",
          "properties": {
            "source": "global",
            "value": "UserOne.surname",
            "inputs": []
          }
        },
        "firstname": {
          "type": "string",
          "properties": {
            "source": "fixed",
            "value": "Alex",
            "inputs": []
          }
        }
      }
    }
  }'

  json = JSON.parse(stuff)


  # puts instance_eval("Faker::Internet.user_name")

  # b = "Internet"

  # x = "user_name"

  # c = []

  # puts "Faker::#{b}".constantize.send(x, *c)
  RequestCreator.generate_enviroment(json)

  puts json

  # puts Fudo::CONFIG['level']

  # puts json.size


  # puts instance_eval("Faker::Internet.instance_method(:user_name)")


  # file = open("../data/basicexample3.txt")
  # testdata = JSON.parse(file.read)

  # requestData = RequestCreator.bake_request(testdata['request'])

  # request = Typhoeus::Request.new(requestData['url'],verbose: true, method: requestData['method'], body: requestData['body'])

  # request.run

  # ResponseChecker.verify_response(testdata['response'], request.response)

end
