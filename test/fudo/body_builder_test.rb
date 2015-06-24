require_relative '../test_helper'

class BodyBuilderTest < Minitest::Test

  def test_invalid_type
    invalid = {'type' => 'invalid'}
    builder = Fudo::BodyBuilder.new(invalid)
    assert_raises TypeError do
      builder.generate_data
    end
  end

  def test_hash
    input = {'user' => {'name' => 'alexander', 'password' => 'pw12345', 'array' => ['test', {'innerhash' => 12}]}}
    schema = Fudo::SchemaGenerator.new(input)
    schema.fudo_test_schema = true
    schema.construct_schema

    builder = Fudo::BodyBuilder.new(schema.output)
    builder.generate_data
    assert_equal builder.result.to_s, input.to_s
  end

  def test_array
    input = ['hello', {'name' => 'alexander', 'password' => 'pw12345'}]
    schema = Fudo::SchemaGenerator.new(input)
    schema.fudo_test_schema = true
    schema.construct_schema

    builder = Fudo::BodyBuilder.new(schema.output)
    builder.generate_data
    assert_equal builder.result.to_s, input.to_s
  end

end
