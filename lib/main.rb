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

simple_fudge_array = '{
  "name": {
    "type": "value",
    "donotmodify": false,
    "restrictions": {
      "required": true,
      "unique": true
    }
  },
  "namearray": {
    "type": "array",
    "donotmodify": false,
    "restrictions": {
      "required": true,
      "unique": false
    },
    "properties": [
      {
        "type": "object",
        "restrictions": {
          "required": true
        },
        "properties": {
          "myobject": {
            "type": "value",
            "donotmodify": false,
            "restrictions": {
              "required": false,
              "unique": true
            }
          }
        }
      },
      {
        "type": "value",
        "donotmodify": true,
        "restrictions": {
          "required": true,
          "unique": true
        }
      },
      {
        "type": "value",
        "donotmodify": true,
        "restrictions": {
          "required": true,
          "unique": true
        }
      }
    ]
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
  },
  "surname": {
    "type": "value",
    "donotmodify": false,
    "restrictions": {
      "required": true,
      "unique": false
    }
  }
}'

  json = JSON.parse(stuff)

  DataGenerator.generate_data(json)

simple_json = JSON.parse('{
  "name": "hi",
  "surname": "bergman",
  "namearray": ["testname","testsurname", 0],
  "name2": {
    "surnamex": "Larson",
    "firstname": "Cecile",
    "whynowork": { "add1" : "addline" }
  }}')

simple_json_array = JSON.parse('{
  "name": "hi",
  "namearray": [{"myobject":"myname"},"testsurname", 0],
  "name2": {
    "surnamex": "Larson",
    "firstname": "Cecile",
    "whynowork": { "add1" : "addline" }
  },
  "surname": "bergman"}')

fudge_spec = JSON.parse(simple_fudge_array)




   df = DataFudger.new(simple_json_array, fudge_spec)


   # puts JSON.pretty_generate(df.origin_data)

   df.run

puts "--------------"
 puts JSON.pretty_generate(df.fudged_data)

end
