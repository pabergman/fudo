#!/usr/bin/env ruby
require 'json'
require 'typhoeus'
require_relative 'response_checker'
require_relative 'data_generator'
require_relative 'fudo'

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
    },
    "namearray": {
      "type": "array",
      "properties": [{
      "type": "string",
      "properties": {
        "source": "ffaker",
        "value": { "class": "Internet", "method": "user_name"},
        "inputs": ["Alexander Bergman"]
      }
    }, {
      "type": "string",
      "properties": {
        "source": "ffaker",
        "value": { "class": "Internet", "method": "user_name"},
        "inputs": ["Alexander Bergman"]
      }
    }]
    }
  }'

  temp = '{"username": "ladida", "age": 20}'

  json = JSON.parse(stuff)

  DataGenerator.generate_data(json)


# puts "\n\n\n"
   puts JSON.pretty_generate(json)

end
