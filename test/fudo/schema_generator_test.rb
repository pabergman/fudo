require_relative '../test_helper'

class SchemaGeneratorTest < Minitest::Test

  def test_empty_object
    schema = Fudo::SchemaGenerator.new({}).output
    assert_equal 'http://json-schema.org/draft-04/schema#', schema['$schema']
    assert_equal 'object', schema['type']
    assert_equal false, schema['additionalProperties']
    assert_equal true, schema['properties'].empty?
  end

  def test_empty_array
    schema = Fudo::SchemaGenerator.new([]).output
    assert_equal 'http://json-schema.org/draft-04/schema#', schema['$schema']
    assert_equal 'array', schema['type']
    assert_equal false, schema['uniqueItems']
    assert_equal true, schema['additionalItems']
    assert_equal 0, schema['minItems']
    assert_equal true, schema['items'].empty?
  end

  def test_schema_type_identifier
    assert_equal 'object', Fudo::SchemaGenerator.schema_type({})
    assert_equal 'array', Fudo::SchemaGenerator.schema_type([])
    assert_equal 'string', Fudo::SchemaGenerator.schema_type('hello world')
    assert_equal 'number', Fudo::SchemaGenerator.schema_type(20)
    assert_equal 'boolean', Fudo::SchemaGenerator.schema_type(true)
    assert_equal 'boolean', Fudo::SchemaGenerator.schema_type(false)
    assert_equal 'null', Fudo::SchemaGenerator.schema_type(nil)
  end

end
