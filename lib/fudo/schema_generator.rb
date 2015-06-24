module Fudo
  class SchemaGenerator

    attr_reader :output


    def initialize(input)
      @input = input
      @output = {}
      output['$schema'] = 'http://json-schema.org/draft-04/schema#'
    end

    def construct_schema(input = @input, output = @output)
      case input
      when Hash
        object(input, output)
      when Array
        array(input, output)
      else
        value(input, output)
      end

    end

    def array(input, output)
      output['type'] = 'array'
      output['uniqueItems'] = false
      output['additionalItems'] = true
      output['minItems'] = input.size.zero? && 0 || 1
      output['items'] = Array.new

      input.each_with_index do |value, index|
        output['items'][index] = Hash.new
        construct_schema(value, output['items'][index])
      end
    end

    def object(input, output)
      output['type'] = 'object'
      output['additionalProperties'] = false
      output['properties'] = Hash.new
      output['required'] = Array.new

      input.each do |key, value|
        output['properties'][key] = Hash.new
        construct_schema(value, output['properties'][key])
        output['required'] << key
      end
    end

    def value(input, output)
      output['type'] = self.class.value_type(input)
      output['default'] = input
    end

    def self.value_type(value)
      case value
      when String
        return "string"
      when Fixnum
        return "number"
      when TrueClass, FalseClass
        return "boolean"
      when NilClass
        return "null"
      end
    end

  end
end
