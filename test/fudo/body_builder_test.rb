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

  def test_ffaker_simple
    schema = {"$schema"=>"http://json-schema.org/draft-04/schema#",
              "type"=>"object",
              "additionalProperties"=>false,
              "properties"=> {"name"=>
                              {"anyOf"=>[{"type"=>"string"}], "default"=>"alexander",
                               "fudo"=>{"source"=>"ffaker",
                                        "class"=>"Name",
                                        "method"=>"first_name",
                                        "unique"=>false,
                                        "donotmodify"=>false,
                                        "inputs"=>[],
                                        "type"=>"value",
                                        "eval" => '' }
                               }
                              },
              "required"=>["name"]
              }

    builder = Fudo::BodyBuilder.new(schema)
    builder.generate_data

    #TODO: Check the output...
  end

  def test_ffaker_inputs
    schema = {"$schema"=>"http://json-schema.org/draft-04/schema#",
              "type"=>"object",
              "additionalProperties"=>false,
              "properties"=> {"email"=>
                              {"anyOf"=>[{"type"=>"string"}], "default"=>"notintendedone",
                               "fudo"=>{"source"=>"ffaker",
                                        "class"=>"Internet",
                                        "method"=>"email",
                                        "unique"=>false,
                                        "donotmodify"=>false,
                                        "inputs"=>["testingemailname"],
                                        "type"=>"value",
                                        "eval" => '' }
                               }
                              },
              "required"=>["email"]
              }

    builder = Fudo::BodyBuilder.new(schema)
    builder.generate_data

    assert_equal true, builder.result['email'].include?('testingemailname')

    #TODO: Check the output...
  end

  def test_eval
    schema = {"$schema"=>"http://json-schema.org/draft-04/schema#",
              "type"=>"object",
              "additionalProperties"=>false,
              "properties"=> {"total"=>
                              {"anyOf"=>[{"type"=>"number"}], "default"=>2,
                               "fudo"=>{"source"=>"eval",
                                        "class"=>"",
                                        "method"=>"",
                                        "unique"=>false,
                                        "donotmodify"=>false,
                                        "inputs"=>["testingemailname"],
                                        "type"=>"value",
                                        "eval" => '10*10' }
                               }
                              },
              "required"=>["total"]
              }

    builder = Fudo::BodyBuilder.new(schema)
    builder.generate_data

    assert_equal 100, builder.result['total']
  end

end
