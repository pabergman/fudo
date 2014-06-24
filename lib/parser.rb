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

    output['apitesting::type'] = "array"
    output['parameters'] = Hash.new
    output['parameters']['min'] = 0
    output['parameters']['max'] = input.length * 2
    output['parameters']['repeat'] = false
    output['innerjson'] = Hash.new

    input.each_with_index do |value, index|

      output['innerjson'][index] = Hash.new

      master(value, output['innerjson'][index])

    end

  end

  def self.hash(input, output)

    output['apitesting::type'] = "hashmap"
    output['innerjson'] = Hash.new

    input.each do |key, value|
      output['innerjson'][key] = Hash.new
      master(value, output['innerjson'][key])
    end
  end

  def self.value(input, output)
    output['apitesting::type'] = "value"
    output['innerjson'] = Hash.new
    output['innerjson']['type'] = "fixed"
    output['innerjson']['value'] = input
    output['innerjson']['required'] = true
  end

end

# shittystring = '[{"status": "new", "name": "alex", "id": 10},{"status": "new", "name": "alex", "id": 11}]'
#shittystring = '{"status": "new", "name": "alex", "id": {"status": "new", "name": [2,3,4,5]}}'


# output = JSON.parse("{}")
# input = JSON.parse(shittystring)


# FudoJsonGenerator.master(input, output)

# puts JSON.pretty_generate(output)


# INPUT

#[{"status": "new", "name": "alex", "id": 10}]


# OUTPUT

# {
#       "apitesting::type": "array",
#       "parameters": {
#         "min": 0,
#         "max": 4,
#         "repeat": false
#       },
#       "innerjson": {
#         "0": {
#           "apitesting::type": "hashmap",
#           "innerjson": {
#             "status": {
#               "apitesting::type": "value",
#               "innerjson": {
#                 "type": "class",
#                 "value": "String",
#                 "required": "true"
#               }
#             },
#             "name": {
#               "apitesting::type": "value",
#               "innerjson": {
#                 "type": "fixed",
#                 "value": "John",
#                 "required": "true"
#               }
#             },
#             "id": {
#               "apitesting::type": "value",
#               "innerjson": {
#                 "type": "class",
#                 "value": "Fixnum",
#                 "required": "true"
#               }
#             }
#           }
#         }
#       }
