require 'ffaker'
require 'active_support/all'
require 'vine'

class DataGenerator

  def self.generate_data(environment)
    environment.each do |key, value|
      case value['type']
      when 'value' then environment[key] = set_value(value['properties']) 
      when 'object' then environment[key] = generate_data(value['properties'])
      when 'array' then environment[key] = handle_array(value['properties'])
      else "oops"
      end
    end
  end

  def self.set_value(properties)
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
    properties.each_with_index do | entry, index | 
      if(entry['type'] == 'value') 
        properties[index] = set_value(entry['properties']) 
      else
        properties[index] = generate_data(entry)
      end
    end
  end

end