#!/usr/bin/env ruby
require 'json'
require 'typhoeus'
require_relative 'response_checker'
require_relative 'data_generator'
require_relative 'data_fudger'
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
    },
    "trueorfalse": {
      "type": "value",
      "properties": {
        "source": "fixed",
        "value": false
      }
    }
  }'

  # simple_fudge = '{ "name": {"required": true, "unique": true, "type": "string", "max_length": 20, "min_length": 2}}'

  simple_fudge = '{
  "name": {
    "type": "value",
    "restrictions": {
      "required": true,
      "unique": true,
      "max_length": 10,
      "min_length": 2
    }
  },
  "surname": {
    "type": "value",
    "restrictions": {
      "required": true,
      "unique": false,
      "max_length": 10,
      "min_length": 2
    }
  }
}'

  json = JSON.parse(stuff)

  DataGenerator.generate_data(json)

simple_json = JSON.parse('{
  "name": "alexander",
  "surname": "bergman"}')

fudge_spec = JSON.parse(simple_fudge)


# puts "\n\n\n"
   # puts JSON.pretty_generate(json)

   df = DataFudger.new(simple_json, fudge_spec)


   puts JSON.pretty_generate(df.origin_data)

   df.run


end
