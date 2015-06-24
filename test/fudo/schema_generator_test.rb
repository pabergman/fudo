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
    assert_equal Hash, schema['items'].class
    assert_equal 1, schema['items']['anyOf'].size
  end

  def test_two_value_array_schema_array
    input = ['hello', 100]
    schema = Fudo::SchemaGenerator.new(input)
    schema.construct_schema
    schema = schema.output
    assert_equal 1, schema['minItems']
    assert_equal 2, schema['items'].size
    assert_equal Array, schema['items'].class
    assert_equal 1, schema['items'][0]['anyOf'].size
    assert_equal 'hello', schema['items'][0]['default']
    assert_equal 100, schema['items'][1]['default']
  end

  def test_two_value_array_single_schema
    input = ['hello', 100]
    schema = Fudo::SchemaGenerator.new(input)
    schema.array_single_schema = true
    schema.construct_schema
    schema = schema.output
    assert_equal 1, schema['minItems']
    assert_equal 1, schema['items'].size
    assert_equal Hash, schema['items'].class
    assert_equal 2, schema['items']['anyOf'].size
    assert_equal 'string', schema['items']['anyOf'][0]['type']
    assert_equal 'number', schema['items']['anyOf'][1]['type']
  end

  def test_string_value
    output = Hash.new
    schema = Fudo::SchemaGenerator.new({})
    schema.value('alexander', output)
    assert_equal 2, output.size
    assert_equal 1, output['anyOf'].size
    assert_equal 'string', output['anyOf'][0]['type']
    assert_equal 'alexander', output['default']
  end

  def test_number_value
    output = Hash.new
    schema = Fudo::SchemaGenerator.new({})
    schema.value(100, output)
    assert_equal 2, output.size
    assert_equal 1, output['anyOf'].size
    assert_equal 'number', output['anyOf'][0]['type']
    assert_equal 100, output['default']
  end

  def test_true_value
    output = Hash.new
    schema = Fudo::SchemaGenerator.new({})
    schema.value(true, output)
    assert_equal 2, output.size
    assert_equal 1, output['anyOf'].size
    assert_equal 'boolean', output['anyOf'][0]['type']
    assert_equal true, output['default']
  end

  def test_false_value
    output = Hash.new
    schema = Fudo::SchemaGenerator.new({})
    schema.value(false, output)
    assert_equal 2, output.size
    assert_equal 1, output['anyOf'].size
    assert_equal 'boolean', output['anyOf'][0]['type']
    assert_equal false, output['default']
  end

  def test_null_value
    output = Hash.new
    schema = Fudo::SchemaGenerator.new({})
    schema.value(nil, output)
    assert_equal 2, output.size
    assert_equal 1, output['anyOf'].size
    assert_equal 'null', output['anyOf'][0]['type']
    assert_equal nil, output['default']
  end

  def test_two_value_fudo_test_schema_array
    input = ['fudo', 101]
    schema = Fudo::SchemaGenerator.new(input)
    schema.fudo_test_schema = true
    schema.construct_schema
    schema = schema.output
    assert_equal 1, schema['minItems']
    assert_equal 2, schema['items'].size
    assert_equal Array, schema['items'].class

    assert_equal 1, schema['items'][0]['anyOf'].size
    assert_equal 'fudo', schema['items'][0]['default']

    assert_equal 1, schema['items'][1]['anyOf'].size
    assert_equal 101, schema['items'][1]['default']

    assert_equal 6, schema['items'][0]['fudo'].size
    assert_equal 'default', schema['items'][0]['fudo']['source']
    assert_equal '', schema['items'][0]['fudo']['class']
    assert_equal '', schema['items'][0]['fudo']['method']
    assert_equal false, schema['items'][0]['fudo']['unique']
    assert_equal false, schema['items'][0]['fudo']['donotmodify']
    assert_equal Array, schema['items'][0]['fudo']['inputs'].class
  end

end
