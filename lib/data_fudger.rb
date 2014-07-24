require 'json'

class DataFudger

  attr_reader :fudged_data
  attr_reader :origin_request

  def initialize(origin_request)
    @fudged_data = Array.new
    @request_body = origin_request['request']['body']
    @origin_request = origin_request
    @fudger_spec = origin_request['request']['bodysrc']
    @depth = Array.new
  end


  def run(input = @origin_request['request']['body'])
    input.each do |key, value|
      case value.class.to_s
      when 'Hash'
        dostuff(key)
        @depth << key
        run(value)
      when 'Array'
        dostuff(key)
        @depth << key
        run_array(value)
      when 'String'
        dostuff(key)
      when 'Fixnum'
        dostuff(key)
      when 'boolean'
        dostuff(key)
      end
    end

    @depth.pop
  end

  def run_array(input = @origin_request['request']['body'])
    input.each_with_index do |value, index|
      case value.class.to_s
      when 'Hash'
        #dostuff(index)
        @depth << index
        run(value)
      when 'Array'
        #dostuff(index)
        run_array(value)
      when 'String'
        # dostuff(index)
      when 'Fixnum'
        # dostuff(index)
      when 'boolean'
        # dostuff(index)
      end
    end
    @depth.pop
  end

  def dostuff(key)

    case @depth.size
    when 0
      depth_0(key)
    when 1
      depth_1(key)
    when 2
      depth_2(key)
    end

  end

  def snowflake(m, i = @fudged_data.size, fudger_spec = @fudger_spec)
    m.each do | key, value|
      case value.class.to_s
      when 'Hash'
        m[key] = snowflake(value, i, fudger_spec[key]['properties'])
      when 'Array'
        snowflake_array(value,i, fudger_spec[key])
      else
        if(fudger_spec[key]['rules']['donotmodify'] == false)
          m[key] = snowflake_value(value)
        end
      end
    end
  end

  def snowflake_array(array, i = @fudged_data.size, fudger_spec = @fudger_spec)
    array.each_with_index do |value, index|
      case value.class.to_s
      when 'Hash'
        snowflake(value, i, fudger_spec['properties'][index]['properties'])
      when 'Array'
        snowflake_array(value)
      else
        if(!fudger_spec['donotmodify'])
          snowflake_value(value)
        end
      end
    end
  end

  def snowflake_value(value,  i = @fudged_data.size)
    if(value.kind_of?(String))
      value << "__#{i}"
    elsif(value.kind_of?(Fixnum))
      value += i
    end
    value
  end

  def add_to_fudged(fudged_request, message, status)
    fudged_request['request'].delete('bodysrc')
    fudged_request['response']['message'] = message
    fudged_request['response']['status'] = status
    @fudged_data << fudged_request
  end


  def depth_0(key)
    y = Marshal.load(Marshal.dump(@origin_request))
    m = y['request']['body']
    snowflake(m)
    delete(y, m, key, @fudger_spec[key]['rules'])

    y = Marshal.load(Marshal.dump(@origin_request))
    m = y['request']['body']
    snowflake(m)
    set_nil(y, m, key, @fudger_spec[key]['rules'])

    if(@fudger_spec[key]['type'] == 'value')
      y = Marshal.load(Marshal.dump(@origin_request))
      m = y['request']['body']
      snowflake(m)
      change_type(y, m, key, @fudger_spec[key]['rules'])
    end

    if(@fudger_spec[key]['type'] == 'value')
      y = Marshal.load(Marshal.dump(@origin_request))
      m = y['request']['body']
      snowflake(m)
      set_unique(y, m, @request_body, key, @fudger_spec[key]['rules'])
    end

  end

  def depth_1(key)
    y = Marshal.load(Marshal.dump(@origin_request))
    m = y['request']['body']
    snowflake(m)
    delete(y, m[@depth[0]], key, @fudger_spec[@depth[0]]['properties'][key]['rules'])

    y = Marshal.load(Marshal.dump(@origin_request))
    m = y['request']['body']
    snowflake(m)
    set_nil(y, m[@depth[0]], key, @fudger_spec[@depth[0]]['properties'][key]['rules'])

    if(@fudger_spec[@depth[0]]['properties'][key]['type'] == 'value')
      y = Marshal.load(Marshal.dump(@origin_request))
      m = y['request']['body']
      snowflake(m)
      change_type(y, m[@depth[0]], key, @fudger_spec[@depth[0]]['properties'][key]['rules'])
    end

    if(@fudger_spec[@depth[0]]['properties'][key]['type'] == 'value')
      y = Marshal.load(Marshal.dump(@origin_request))
      m = y['request']['body']
      snowflake(m)
      set_unique(y, m[@depth[0]], @request_body[@depth[0]], key, @fudger_spec[@depth[0]]['properties'][key]['rules'])
    end

  end

  def depth_2(key)

    y = Marshal.load(Marshal.dump(@origin_request))
    m = y['request']['body']
    snowflake(m)
    delete(y, m[@depth[0]][@depth[1]], key, @fudger_spec[@depth[0]]['properties'][@depth[1]]['properties'][key]['rules'])

    y = Marshal.load(Marshal.dump(@origin_request))
    m = y['request']['body']
    snowflake(m)
    set_nil(y, m[@depth[0]][@depth[1]], key, @fudger_spec[@depth[0]]['properties'][@depth[1]]['properties'][key]['rules'])

    if(@fudger_spec[@depth[0]]['properties'][@depth[1]]['properties'][key]['type'] == 'value')
      y = Marshal.load(Marshal.dump(@origin_request))
      m = y['request']['body']
      snowflake(m)
      change_type(y, m[@depth[0]][@depth[1]], key, @fudger_spec[@depth[0]]['properties'][@depth[1]]['properties'][key]['rules'])
    end

    if(@fudger_spec[@depth[0]]['properties'][@depth[1]]['properties'][key]['type'] == 'value')
      y = Marshal.load(Marshal.dump(@origin_request))
      m = y['request']['body']
      snowflake(m)
      set_unique(y, m[@depth[0]][@depth[1]], @request_body[@depth[0]][@depth[1]], key, @fudger_spec[@depth[0]]['properties'][@depth[1]]['properties'][key]['rules'])
    end

  end

  def delete(y, m, key, rules)
    m.delete(key)
    if(rules['required'])
      add_to_fudged(y, "#{key} is a required field", 400)
    else
      add_to_fudged(y, "#{key} is not a required field",200)
    end
  end

  def set_nil(y, m, key, rules)
    m[key] = nil
    if(rules['required'])
      add_to_fudged(y, "#{key} is a required field (nil error)", 400)
    else
      add_to_fudged(y, "#{key} is not a required field (nil error)",200)
    end
  end

  def change_type(y, m, key, rules)
    if(rules['value-type'] == "String")
      m[key] = rand(10000)
      add_to_fudged(y, "#{key} is a should be a string!", 400)
    elsif(rules['value-type'] == "Fixnum")
      m[key] = m[key].to_s
      add_to_fudged(y, "#{key} is a should be a integer!", 400)
    elsif(rules['value-type'] == "boolean")
      m[key] = "true"
      add_to_fudged(y, "#{key} is a should be a boolean!", 400)
    end
  end

  def set_unique(y, m, original, key, rules)
    m[key] = original[key]
    if(rules['unique'])
      add_to_fudged(y, "#{key} should be unique",  409)
    else
      add_to_fudged(y, "#{key} should not need to be a unique field", 200)
    end
  end

end
