#!/usr/bin/env ruby
require 'json'
require 'typhoeus'
require 'vine'
require_relative 'response_checker'
require_relative 'data_generator'
require_relative 'data_fudger'
require_relative 'fudo'


if __FILE__ == $0

  request = '{
  "request": {
    "method": "POST",
    "url": "http://localhost:7000/thing/",
    "headers": {},
    "body": {
      "name": {
        "6r0dT4&;29Slo-<5Uc-gu9M12`$B3O": true,
        "innerjson": {
          "type": "fixed",
          "value": "John",
          "inputs": ""
        }
      },
      "status": {
        "6r0dT4&;29Slo-<5Uc-gu9M12`$B3O": true,
        "innerjson": {
          "type": "generated",
          "value": "RandomNumber",
          "inputs": ""
        }
      }
    }
  },
  "response": {
    "body": {
      "apitesting::type": "hashmap",
      "innerjson": {
        "status": {
          "apitesting::type": "value",
          "innerjson": {
            "type": "class",
            "value": "String",
            "required": "true"
          }
        },
        "name": {
          "apitesting::type": "value",
          "innerjson": {
            "type": "class",
            "value": "String",
            "required": "true"
          }
        },
        "id": {
          "apitesting::type": "value",
          "innerjson": {
            "type": "class",
            "value": "Fixnum",
            "required": "true"
          }
        }
      }
    },
    "headers": {},
    "status": 200,
    "message": "should pass"
  }
}'

  stuff = '{
  "name": {
    "type": "value",
    "properties": {
      "source": "ffaker",
      "value": {
        "class": "Internet",
        "method": "user_name"
      },
      "inputs": [
      ]
    }
  },
  "namearray": {
    "type": "array",
    "properties": [
      {
        "type": "object",
        "properties": {
          "myobject": {
            "type": "value",
            "properties": {
              "source": "ffaker",
              "value": {
                "class": "Name",
                "method": "last_name"
              },
              "inputs": []
            }
          }
        }
      },
      {
        "type": "value",
        "properties": {
          "source": "ffaker",
          "value": {
            "class": "Internet",
            "method": "user_name"
          },
          "inputs": []
        }
      }
    ]
  },
  "name2": {
    "type": "object",
    "properties": {
      "surnamex": {
        "type": "value",
        "properties": {
          "source": "ffaker",
          "value": {
            "class": "Name",
            "method": "last_name"
          },
          "inputs": []
        }
      },
      "firstname": {
        "type": "value",
        "properties": {
          "source": "ffaker",
          "value": {
            "class": "Name",
            "method": "first_name"
          },
          "inputs": []
        }
      },
      "whynowork": {
        "type": "object",
        "properties": {
          "add1": {
          "type": "value",
          "properties": {
            "source": "fixed",
            "value": "addline1"
          }
        }
        }
      }
    }
  },
  "surname": {
    "type": "value",
    "properties": {
      "source": "ffaker",
      "value": {
        "class": "Internet",
        "method": "user_name"
      },
      "inputs": [
        "Alexander Bergman"
      ]
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


  full_request = JSON.parse(request)

  json = JSON.parse(stuff)

  DataGenerator.generate_data(json)

  # puts JSON.pretty_generate(json)

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


  full_request['request']['body'] = json

  df = DataFudger.new(full_request, fudge_spec)
  puts JSON.pretty_generate(df.origin_request)


  df.run

  puts '--------------'
  puts df.fudged_data.size
  puts "--------------"
  puts JSON.pretty_generate(df.fudged_data)

end
