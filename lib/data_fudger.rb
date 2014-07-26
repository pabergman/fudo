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
      value.prepend("#{i}__")
    elsif(value.kind_of?(Fixnum))
      value += i
    end
    value
  end

  def depth_0(key)

    clone = clone_request(key)
    delete(clone[0], clone[1], key, @fudger_spec[key]['rules'])

    clone = clone_request(key)
    set_nil(clone[0], clone[1], key, @fudger_spec[key]['rules'])

    if(@fudger_spec[key]['type'] == 'value')
      clone = clone_request(key)
      change_type(clone[0], clone[1], key, @fudger_spec[key]['rules'])
      clone = clone_request(key)
      set_unique(clone[0], clone[1], @request_body, key, @fudger_spec[key]['rules'])
    end

    if(@fudger_spec[key]['rules']['value-type'] == 'boolean')
      clone = clone_request(key)
      boolean_int(clone[0], clone[1], key)
      clone = clone_request(key)
      boolean_string(clone[0], clone[1], key)
    end

    if(@fudger_spec[key]['rules']['value-type'] == 'password' &&
       @fudger_spec[key]['rules']['donotmodify'] == false)
      clone = clone_request(key)
      short_password(clone[0], clone[1], key)
      clone = clone_request(key)
      weak_password(clone[0], clone[1], key)
    end

  end

  def depth_1(key)
    clone = clone_request(key)
    delete(clone[0], clone[1][@depth[0]], key, @fudger_spec[@depth[0]]['properties'][key]['rules'])

    clone = clone_request(key)
    set_nil(clone[0], clone[1][@depth[0]], key, @fudger_spec[@depth[0]]['properties'][key]['rules'])

    if(@fudger_spec[@depth[0]]['properties'][key]['type'] == 'value')
      clone = clone_request(key)
      change_type(clone[0], clone[1][@depth[0]], key, @fudger_spec[@depth[0]]['properties'][key]['rules'])
      clone = clone_request(key)
      set_unique(clone[0], clone[1][@depth[0]], @request_body[@depth[0]], key, @fudger_spec[@depth[0]]['properties'][key]['rules'])
    end

    if(@fudger_spec[@depth[0]]['properties'][key]['rules']['value-type'] == 'boolean')
      clone = clone_request(key)
      boolean_int(clone[0], clone[1][@depth[0]], key)
      clone = clone_request(key)
      boolean_string(clone[0], clone[1][@depth[0]], key)
    end

    if(@fudger_spec[@depth[0]]['properties'][key]['rules']['value-type'] == 'password' &&
       @fudger_spec[@depth[0]]['properties'][key]['rules']['donotmodify'] == false)
      clone = clone_request(key)
      short_password(clone[0], clone[1][@depth[0]], key)
      clone = clone_request(key)
      weak_password(clone[0], clone[1][@depth[0]], key)
    end

  end

  def depth_2(key)

    clone = clone_request(key)
    delete(clone[0], clone[1][@depth[0]][@depth[1]], key, @fudger_spec[@depth[0]]['properties'][@depth[1]]['properties'][key]['rules'])

    clone = clone_request(key)
    set_nil(clone[0], clone[1][@depth[0]][@depth[1]], key, @fudger_spec[@depth[0]]['properties'][@depth[1]]['properties'][key]['rules'])

    if(@fudger_spec[@depth[0]]['properties'][@depth[1]]['properties'][key]['type'] == 'value')
      clone = clone_request(key)
      change_type(clone[0], clone[1][@depth[0]][@depth[1]], key, @fudger_spec[@depth[0]]['properties'][@depth[1]]['properties'][key]['rules'])
      clone = clone_request(key)
      set_unique(clone[0], clone[1][@depth[0]][@depth[1]], @request_body[@depth[0]][@depth[1]], key, @fudger_spec[@depth[0]]['properties'][@depth[1]]['properties'][key]['rules'])
    end

    if(@fudger_spec[@depth[0]]['properties'][@depth[1]]['properties'][key]['rules']['value-type'] == 'boolean')
      clone = clone_request(key)
      boolean_int(clone[0], clone[1][@depth[0]][@depth[1]], key)
      clone = clone_request(key)
      boolean_string(clone[0], clone[1][@depth[0]][@depth[1]], key)
    end

    if(@fudger_spec[@depth[0]]['properties'][@depth[1]]['properties'][key]['rules']['value-type'] == 'password' &&
       @fudger_spec[@depth[0]]['properties'][@depth[1]]['properties'][key]['rules']['donotmodify'] == false)
      clone = clone_request(key)
      short_password(clone[0], clone[1][@depth[0]][@depth[1]], key)
      clone = clone_request(key)
      weak_password(clone[0], clone[1][@depth[0]][@depth[1]], key)
    end

  end

  def clone_request(key)
    y = Marshal.load(Marshal.dump(@origin_request))
    snowflake(y['request']['body'])
    return [y, y['request']['body']]
  end

  def add_to_fudged(fudged_request, message, status, severity=100)
    fudged_request['request'].delete('bodysrc')
    fudged_request['response']['message'] = message
    fudged_request['response']['status'] = status
    fudged_request['response']['severity'] = severity
    @fudged_data << fudged_request
  end

  def boolean_int(y, m, key)
    if(m[key])
      m[key] = 1
    else
      m[key] = 0
    end
    add_to_fudged(y, "The key #{key} switched from boolean to an equivalent smallint.", 400, 2)
  end

  def boolean_string(y, m, key)
    if(m[key])
      m[key] = "true"
    else
      m[key] = "false"
    end
    add_to_fudged(y, "The key #{key} switched from boolean to an equivalent string.", 400, 2)
  end

  def short_password(y, m, key)
    m[key] = "nK!c"
    add_to_fudged(y, "The password for key #{key} was set to nK!c and is too short.", 400, 1)
  end

  def weak_password(y, m, key)
    m[key] = "helloworld"
    add_to_fudged(y, "The password for key #{key} was set to helloworld and is considered weak.", 400, 1)
  end

  def delete(y, m, key, rules)
    m.delete(key)
    if(rules['required'])
      add_to_fudged(y, "The key #{key} was removed from the JSON object.", 400, 1)
    else
      add_to_fudged(y, "The key #{key} was removed from the JSON object.", 200, 2)
    end
  end

  def set_nil(y, m, key, rules)
    m[key] = nil
    if(rules['required'])
      add_to_fudged(y, "The value for #{key} was set to null.", 400, 1)
    else
      add_to_fudged(y, "The value for #{key} was set to null.", 200, 2)
    end
  end

  def change_type(y, m, key, rules)
    if(rules['value-type'] == "String")
      m[key] = false
      add_to_fudged(y, "Replaced #{key} with an boolean instead of string.", 400, 2)
    elsif(rules['value-type'] == "Fixnum")
      m[key] = "wrongvalue"
      add_to_fudged(y, "Replaced #{key} with a string instead of integer.", 400, 1)
    elsif(rules['value-type'] == "boolean")
      m[key] = "wrongvalue"
      add_to_fudged(y, "Replaced #{key} with a string instead of boolean.", 400, 1)
    end

  end

  def set_unique(y, m, original, key, rules)
    m[key] = original[key]
    if(rules['unique'])
      add_to_fudged(y, "Tried to make two requests with the same #{key}, should need to be unique.",  409, 1)
    else
      add_to_fudged(y, "Tried to make two requests with the same #{key}, should not need to be unique!", 200, 1)
    end
  end

end
