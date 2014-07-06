require 'ffaker'
require 'active_support/all'
require 'vine'

class DataGenerator

  def self.generate_data(environment)
     # puts environment['type']
    # puts environment.class
    environment.each do |key, value|
      puts value['type']
      case value['type']
      when 'string' then environment[key] = set_value(value['properties']) 
      when 'object' then environment[key] = generate_data(value['properties'])
      when 'array' then environment[key] = handle_array(value['properties'])
      else "oops"
      end
             # puts key + " : WTF : " + environment[key].to_s

    end
  end

  def self.set_value(properties)
    # puts "-----------"
    # puts "SET_VALUE:  " + properties['source']
    case properties['source']
    when 'ffaker' then value = fake_value(properties['value'],properties['inputs'])
    when 'global' then value = Fudo::GLOBAL_VARIABLES.access(properties['value'])
    when 'fixed' then value = properties['value']
    when 'runtest' then #add support later
    when 'previoustest' then #do stuff
    when 'custom' then #dostuff
    when 'environmental' then #dostuff
    else puts "#{properties['source']} is not supported."
    end
    value
  end

  def self.fake_value(value, inputs)
    "Faker::#{value['class']}".constantize.send(value['method'], *inputs)
  end

  def self.handle_array(properties)
    # puts "hi"
    # puts "---------"
    # puts properties[0]
    # puts "---------"
    properties.each_with_index do | entry, index | 
      # puts index
      # puts entry.class
      # puts generate_data(entry)
      if(entry['type'] != 'array' && entry['type'] != 'object') 
        properties[index] = set_value(entry['properties']) 
      else
        properties[index] = generate_data(entry)
      end
      # puts properties[index]
    end
    # puts properties
  end
end