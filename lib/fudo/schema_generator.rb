module Fudo
  class SchemaGenerator
    def construct_schema(json_source)

    end

    def self.schema_type(type)
      case type
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
