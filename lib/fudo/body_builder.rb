require 'ffaker'
require 'active_support/all'

module Fudo
  class BodyBuilder

    attr_reader :result, :schema

    def initialize(schema, previoustest = [], global = {})
      @schema = schema
      @global = global
      @previoustest = []
      @result = Marshal.load(Marshal.dump(schema))
    end

    def generate_data(result = @result)
      type = result['type'] || result['fudo']['type']
      case type
      when 'object' then @result = handle_object(result)
      when 'array' then @result = handle_array(result)
      else raise TypeError, 'Unknown type'
      end
    end

    def handle_object(result)
      result['properties'].each do |key, value|
        type = value['type'] || value['fudo']['type']
        case type
        when 'value' then result['properties'][key] = set_value(value)
        when 'object' then result['properties'][key] = handle_object(value)
        when 'array' then result['properties'][key] = handle_array(value)
        else raise TypeError, 'Unknown type'
        end
      end
    end

    def set_value(result)
      case result['fudo']['source']
      when 'ffaker' then value = fake_value(result['value'],result['inputs'])
      when 'default' then value = result['default']
      when 'global' then value = Fudo::GLOBAL_VARIABLES.access(properties['value'])
      when 'runtest' then #add support later
      when 'previoustest' then #do stuff
      when 'custom' then #dostuff
      when 'environmental' then #dostuff
      else puts "#{result['source']} is not supported."
      end
      value
    end

    def fake_value(value, inputs)
      "Faker::#{value['class']}".constantize.send(value['method'], *inputs)
    end

    def handle_array(result)

      result['items'].each_with_index do | entry, index |
        type = entry['type'] || entry['fudo']['type']
        case type
        when 'value' then result['items'][index] = set_value(entry)
        when 'object' then result['items'][index] = handle_object(entry)
        when 'array' then result['items'][index] = handle_array(entry)
        else "oops"
        end
      end
    end

  end
end
