require 'json'

class DataFudger

  attr_reader :fudged_data
  attr_reader :origin_data
  attr_reader :origin_request

  def initialize(origin_data, fudger_spec, origin_request)
    @fudged_data = Array.new
    @origin_data = origin_data
    @origin_request = origin_request
    @fudger_spec = fudger_spec
    @depth = Array.new
  end


  def run(input = @origin_data)
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

  def run_array(input = @origin_data)
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


  def depth_0(key)
  	y = Marshal.load(Marshal.dump(@origin_request))
  	m = y['request']['body']
    # m = Marshal.load(Marshal.dump(@origin_data))
    snowflake(m)
    m.delete(key)
    if(@fudger_spec[key]['restrictions']['required'])
      # @fudged_data << {"status" => 400, "message"=> "#{key} is a required field", "body" => m}
      y['response']['message'] = "#{key} is a required field"
      y['response']['status'] = 400;
      @fudged_data << y
    else
      @fudged_data << {"status" => 200, "message"=> "#{key} is not a required field", "body" => m}
    end

    if(@fudger_spec[key]['type'] == 'value')
      m = Marshal.load(Marshal.dump(@origin_data))
      snowflake(m)
      m[key] = @origin_data[key]
      if(@fudger_spec[key]['restrictions']['unique'])
        @fudged_data << {"status" => 400, "message"=> "#{key} should be unique", "body" => m}
      else
        @fudged_data << {"status" => 200, "message"=> "#{key} should not need to be a unique field", "body" => m}
      end
    end
  end

  def depth_1(key)
    m = Marshal.load(Marshal.dump(@origin_data))
    snowflake(m)
    if(m[@depth[0]].class.to_s == 'Hash')
      m[@depth[0]].delete(key)
    else
      m[@depth[0]][key] = nil
    end

    if(@fudger_spec[@depth[0]]['properties'][key]['restrictions']['required'])
      @fudged_data << {"status" => 400, "message"=> "#{key} is a required field", "body" => m}
    else
      @fudged_data << {"status" => 200, "message"=> "#{key} is not a required field", "body" => m}

    end

    if(@fudger_spec[@depth[0]]['properties'][key]['type'] == 'value')
      m = Marshal.load(Marshal.dump(@origin_data))
      snowflake(m)
      m[@depth[0]][key] = @origin_data[@depth[0]][key]
      if(@fudger_spec[@depth[0]]['properties'][key]['restrictions']['unique'])
        @fudged_data << {"status" => 400, "message"=> "#{key} should be unique", "body" => m }
      else
        @fudged_data << {"status" => 200, "message"=> "#{key} should not need to be a unique field", "body" => m}
      end
    end
  end

  def depth_2(key)
    m = Marshal.load(Marshal.dump(@origin_data))
    snowflake(m)
    m[@depth[0]][@depth[1]].delete(key)
    if(@fudger_spec[@depth[0]]['properties'][@depth[1]]['properties'][key]['restrictions']['required'])
      @fudged_data << {"status" => 400, "message"=> "#{key} is a required field", "body" => m}
    else
      @fudged_data << {"status" => 200, "message"=> "#{key} is not a required field", "body" => m}
    end

    if(@fudger_spec[@depth[0]]['properties'][@depth[1]]['properties'][key]['type'] == 'value')
      m = Marshal.load(Marshal.dump(@origin_data))
      snowflake(m)
      m[@depth[0]][@depth[1]][key] = @origin_data[@depth[0]][@depth[1]][key]
      if(@fudger_spec[@depth[0]]['properties'][@depth[1]]['properties'][key]['restrictions']['unique'])
        @fudged_data << {"status" => 400, "message"=> "#{key} should be unique", "body" => m }
      else
        @fudged_data << {"status" => 200, "message"=> "#{key} should not need to be a unique field", "body" => m}
      end
    end

  end

end
