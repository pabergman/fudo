require 'json'

class DataFudger

  attr_reader :fudged_data
  attr_reader :origin_request

  def initialize(origin_request, fudger_spec)
    @fudged_data = Array.new
    @request_body = origin_request['request']['body']
    @origin_request = origin_request
    @fudger_spec = fudger_spec
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
        if(fudger_spec[key]['donotmodify'] == false)
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
        if(fudger_spec['donotmodify'] == false)
          snowflake_value(value)
        end
      end
    end
  end

  def snowflake_value(value,  i = @fudged_data.size)
    if(value.class.to_s == 'String')
      value << "__#{i}"
    elsif(value.class.to_s == 'Fixnum')
      value += 1
    end
    value
  end

  def add_to_fudged(fudged_request, message, status)
    fudged_request['response']['message'] = message
    fudged_request['response']['status'] = status
    @fudged_data << fudged_request
  end


  def depth_0(key)
    y = Marshal.load(Marshal.dump(@origin_request))
    m = y['request']['body']
    snowflake(m)
    m.delete(key)
    if(@fudger_spec[key]['restrictions']['required'])
      add_to_fudged(y, "#{key} is a required field", 400)
    else
      add_to_fudged(y, "#{key} is not a required field",200)
    end

    if(@fudger_spec[key]['type'] == 'value')
      y = Marshal.load(Marshal.dump(@origin_request))
      m = y['request']['body']
      snowflake(m)
      m[key] = @request_body[key]
      if(@fudger_spec[key]['restrictions']['unique'])
        add_to_fudged(y, "#{key} should be unique",  400)
      else
        add_to_fudged(y, "#{key} should not need to be a unique field", 200)
      end
    end
  end

  def depth_1(key)
    y = Marshal.load(Marshal.dump(@origin_request))
    m = y['request']['body']
    snowflake(m)
    if(m[@depth[0]].class.to_s == 'Hash')
      m[@depth[0]].delete(key)
    else
      m[@depth[0]][key] = nil
    end

    if(@fudger_spec[@depth[0]]['properties'][key]['restrictions']['required'])
      add_to_fudged(y, "#{key} is a required field", 400)
    else
      add_to_fudged(y, "#{key} is not a required field", 200)
    end

    if(@fudger_spec[@depth[0]]['properties'][key]['type'] == 'value')
      y = Marshal.load(Marshal.dump(@origin_request))
      m = y['request']['body']
      snowflake(m)
      m[@depth[0]][key] = @request_body[@depth[0]][key]
      if(@fudger_spec[@depth[0]]['properties'][key]['restrictions']['unique'])
        add_to_fudged(y, "#{key} should be unique",  400)
      else
        add_to_fudged(y, "#{key} should not need to be a unique field", 200)
      end
    end
  end

  def depth_2(key)
    y = Marshal.load(Marshal.dump(@origin_request))
    m = y['request']['body']
    snowflake(m)
    m[@depth[0]][@depth[1]].delete(key)
    if(@fudger_spec[@depth[0]]['properties'][@depth[1]]['properties'][key]['restrictions']['required'])
      add_to_fudged(y, "#{key} is a required field", 400)
    else
      add_to_fudged(y, "#{key} is not a required field", 200)
    end

    if(@fudger_spec[@depth[0]]['properties'][@depth[1]]['properties'][key]['type'] == 'value')
      y = Marshal.load(Marshal.dump(@origin_request))
      m = y['request']['body']
      snowflake(m)
      m[@depth[0]][@depth[1]][key] = @request_body[@depth[0]][@depth[1]][key]
      if(@fudger_spec[@depth[0]]['properties'][@depth[1]]['properties'][key]['restrictions']['unique'])
        add_to_fudged(y, "#{key} should be unique",  400)
      else
        add_to_fudged(y, "#{key} should not need to be a unique field", 200)
      end
    end

  end

end
