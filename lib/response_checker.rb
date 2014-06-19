require 'json'

class ResponseChecker

  def self.verify_response(expected_data, response_data)
    verify_status(expected_data['status'], response_data.code)
    response_body = JSON.parse(response_data.body)
    expected_body = expected_data['body']
    verify_body(expected_body, response_body)
  end

  #Use metadata to distinguish what we're dealing with
  def self.verify_body(expected_body, response_body)
    case expected_body['apitesting::type']
    when "hashmap" then handle_map(expected_body['innerjson'], response_body)
    when "value" then  check_value(expected_body['innerjson'], response_body)
    when "array" then  handle_array(expected_body['innerjson'], expected_body['parameters'], response_body)
    else abort('Not a hal or guru error! Still broke though, sad times.')
    end
  end

  #If it's a map, we just bounce it back up
  def self.handle_map(expected_body, response_body)
    expected_body.each do |key, value|
      verify_body(value,response_body[key])
    end
  end

  #If it's an array, do really annoying things
  def self.handle_array(expected_body, parameters, response_body)
    if parameters['max'] <= response_body.length && parameters['max'] != -1
      puts "Too big"
    end

    if parameters['min'] >= response_body.length
      puts "Too Small"
    end

    if parameters['repeat'] == true
      response_body.each do |value|
        verify_body(expected_body['0'], value)
      end
    else
      expected_body.each do |key, value|
        verify_body(value, response_body[key.to_i])
      end
    end
  end

  #Check the value of the field
  def self.check_value(expected_body, response_body)
    case expected_body['type']
    when "class" then response_value = response_body.class.inspect
    when "fixed" then response_value = response_body
    else abort('Not a hal or guru error! Still broke though, sad times.')
    end

    if response_value != expected_body['value']
      puts "I got  #{response_value}  but expected  #{expected_body['value']}"
    end
  end

  def self.verify_status(expected_status, response_status)
    if expected_status != response_status
      puts "WRONG! Status code that is :("
    end
  end

end