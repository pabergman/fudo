module Fudo
  class SchemaGenerator

    attr_reader :output

    def initialize(input)
      @input = input
      @output = {}
      construct_schema(@input, @output)
    end

    def construct_schema(input, output)
      case input
      when Hash
        object(input, output)
      when Array
        array(input, output)
      else
        value(input, output)
      end

      output['$schema'] = 'http://json-schema.org/draft-04/schema#'
    end

    def array(input, output)
      output['type'] = 'array'
    end

    def object(input, output)
      output['type'] = 'object'
    end

    def value(input, output)

    end

    def self.schema_type(value)
      case value
      when Hash
        return "object"
      when Array
        return "array"
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
