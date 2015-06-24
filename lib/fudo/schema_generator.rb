module Fudo
  class SchemaGenerator

    attr_reader :output
    attr_accessor :array_single_schema, :fudo_test_schema

    def initialize(input)
      @input = input
      @output = {}
      output['$schema'] = 'http://json-schema.org/draft-04/schema#'
    end

    def array_single_schema=(boolean)
      if boolean
        @array_single_schema = true
        @fudo_test_schema = false
      else
        @array_single_schema = false
      end
    end

    def fudo_test_schema=(boolean)
      if boolean
        @fudo_test_schema = true
        @array_single_schema = false
      else
        @fudo_test_schema = false
      end
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

    def array_schema(input, output)
      case input
      when Hash
        object(input, output)
      when Array
        array(input, output)
      else
        array_single_schema(input, output)
      end

    end

    def array(input, output)
      output['type'] = 'array'
      output['uniqueItems'] = false
      output['additionalItems'] = true
      output['minItems'] = input.size.zero? && 0 || 1

      if @array_single_schema || input.size == 1 && !@fudo_test_schema
        output['items'] = Hash.new
        output['items']['anyOf'] = Array.new
        input.each_with_index do |value, index|
          array_schema(value, output['items']['anyOf'])
        end
      else
        output['items'] = Array.new
        input.each_with_index do |value, index|
          output['items'][index] = Hash.new
          construct_schema(value, output['items'][index])
        end
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

    def array_single_schema(input, output)
      output << { 'type' => self.class.value_type(input) }
    end

    def value(input, output)
      output['anyOf'] = Array.new
      output['anyOf'] << { 'type' => self.class.value_type(input) }
      output['default'] = input
      if @fudo_test_schema
        hash = {
          'source' => 'default',
          'class' => '',
          'method' => '',
          'unique' => false,
          'donotmodify' => false,
          'inputs' => [],
          'type' => 'value',
          'eval' => ''
        }
        output['fudo'] = hash
      end
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
