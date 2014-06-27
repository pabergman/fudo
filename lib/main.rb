#!/usr/bin/env ruby
require 'json'
require 'typhoeus'
require_relative 'response_checker'

class RequestCreator

  # def self.create_request(request)
  #   request['body'] = create_body(request['body'])
  # end

  # def self.create_body(request)

  # end


  def self.bake_request(request)
    request['body'] = bake_body(request['body'])
    request
  end

  def self.bake_body(body)
    body.each do |key, value|
      if value['6r0dT4&;29Slo-<5Uc-gu9M12`$B3O'] == true
        body[key] = set_value(value['innerjson'])
      else
        body[key] = bake_body(value['innerjson'])
      end
    end
    body
  end

  def self.set_value(stuff)
    if(stuff['type'] == "fixed")
      stuff['value']
    elsif(stuff['type'] == "generated")
      generate_values(stuff['value'], stuff['inputs'])
    end
  end

  def self.generate_values(value, inputs)
    Object.const_get(value).generate_value(inputs)
  end

  def self.fetch_values
    #Pain! Do this later when I figured it out
  end

end

class RandomName
  def self.generate_value(inputs=false)
    "OneName"
  end
end

class RandomNumber
  def self.generate_value(inputs=false)
    rand(100)
  end
end

if __FILE__ == $0

  file = open("../data/basicexample3.txt")
  testdata = JSON.parse(file.read)

  requestData = RequestCreator.bake_request(testdata['request'])

  request = Typhoeus::Request.new(requestData['url'],verbose: true, method: requestData['method'], body: requestData['body'])

  request.run

  ResponseChecker.verify_response(testdata['response'], request.response)

end