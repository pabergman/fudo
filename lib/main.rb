#!/usr/bin/env ruby
require 'json'
require 'typhoeus'
require_relative 'response_checker'
require_relative 'data_generator'
require_relative 'fudo'

if __FILE__ == $0

  stuff = '{
    "name": {
      "type": "value",
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
          "type": "value",
          "properties": {
            "source": "ffaker",
            "value": {"class":"Name", "method": "last_name"},
            "inputs": []
          }
        },
        "firstname": {
          "type": "value",
          "properties": {
            "source": "ffaker",
            "value": {"class":"Name", "method": "first_name"},
            "inputs": []
          }
        }
      }
    },
    "namearray": {
      "type": "array",
      "properties": [{
      "type": "value",
      "properties": {
        "source": "ffaker",
        "value": { "class": "Internet", "method": "user_name"},
        "inputs": []
      }
    }, {
      "type": "value",
      "properties": {
        "source": "ffaker",
        "value": { "class": "Internet", "method": "user_name"},
        "inputs": []
      }
    }]
    }
  }'


  json = JSON.parse(stuff)

  DataGenerator.generate_data(json)


# puts "\n\n\n"
   puts JSON.pretty_generate(json)

end
