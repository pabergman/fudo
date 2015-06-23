require_relative '../test_helper'

class SchemaGeneratorTest < Minitest::Test

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

