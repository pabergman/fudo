#!/usr/bin/env ruby
require 'json'
require 'typhoeus'
require 'vine'
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
        "source": "global",
        "value": "UserOne.inner.stuff"
      }
    }
  }'

  # simple_fudge = '{ "name": {"required": true, "unique": true, "type": "string", "max_length": 20, "min_length": 2}}'

  simple_fudge = '{
  "name": {
    "type": "value",
    "donotmodify": false,
    "restrictions": {
      "required": true,
      "unique": true
    }
  },
  "surname": {
    "type": "value",
    "donotmodify": false,
    "restrictions": {
      "required": true,
      "unique": false
    }
  },
  "namearray": {
    "type": "value",
    "donotmodify": false,
    "restrictions": {
      "required": true,
      "unique": false
    }
  },
  "name2": {
    "type": "object",
    "restrictions": {
      "required": true
    },
    "properties": {
      "surnamex": {
        "type": "value",
        "donotmodify": false,
        "restrictions": {
          "required": false,
          "unique": true
        }
      },
      "firstname": {
        "type": "value",
        "donotmodify": true,
        "restrictions": {
          "required": true,
          "unique": true
        }
      },
      "whynowork": {
        "type": "object",
        "restrictions": {
          "required": true
        },
        "properties": {
          "add1": {
            "type": "value",
            "restrictions": {
              "required": true,
              "unique": true
            }
          }
        }
      }
    }
  }
}'

  json = JSON.parse(stuff)

  DataGenerator.generate_data(json)

simple_json = JSON.parse('{
  "name": "hi",
  "surname": "bergman",
  "namearray": [{"city":"london"}],
  "name2": {
    "surnamex": "Larson",
    "firstname": "Cecile",
    "whynowork": { "add1" : "addline" }
  }}')

fudge_spec = JSON.parse(simple_fudge)




   df = DataFudger.new(simple_json, fudge_spec)


   puts JSON.pretty_generate(df.origin_data)

   df.run

puts "--------------"
puts df.fudged_data

end
