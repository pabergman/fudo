require_relative '../test_helper'

class SchemaGeneratorTest < Minitest::Test

  def test_empty_object
    schema = Fudo::SchemaGenerator.new({})
    schema.construct_schema
    schema = schema.output
    assert_equal 'http://json-schema.org/draft-04/schema#', schema['$schema']
    assert_equal 'object', schema['type']
    assert_equal false, schema['additionalProperties']
    assert_equal true, schema['properties'].empty?
  end

  def test_empty_array
    schema = Fudo::SchemaGenerator.new([])
    schema.construct_schema
    schema = schema.output
    assert_equal 'http://json-schema.org/draft-04/schema#', schema['$schema']
    assert_equal 'array', schema['type']
    assert_equal false, schema['uniqueItems']
    assert_equal true, schema['additionalItems']
    assert_equal 0, schema['minItems']
    assert_equal true, schema['items'].empty?
  end

  def test_schema_type_identifier
    assert_equal 'string', Fudo::SchemaGenerator.value_type('hello world')
    assert_equal 'number', Fudo::SchemaGenerator.value_type(20)
    assert_equal 'boolean', Fudo::SchemaGenerator.value_type(true)
    assert_equal 'boolean', Fudo::SchemaGenerator.value_type(false)
    assert_equal 'null', Fudo::SchemaGenerator.value_type(nil)
  end

  def test_single_value_hash
    input = {'name' => 'alexander'}
    schema = Fudo::SchemaGenerator.new(input)
    schema.construct_schema
    schema = schema.output
    assert_equal 1, schema['properties'].size
    assert_equal 'alexander', schema['properties']['name']['default']
    assert_equal 1, schema['required'].size
    assert_equal 'name', schema['required'][0]
  end

  def test_single_value_array
    input = ['hello']
    schema = Fudo::SchemaGenerator.new(input)
    schema.construct_schema
    schema = schema.output
    assert_equal 1, schema['minItems']
    assert_equal 1, schema['items'].size
    assert_equal 'string', schema['items'][0]['type']
    assert_equal 'hello', schema['items'][0]['default']
  end

end
