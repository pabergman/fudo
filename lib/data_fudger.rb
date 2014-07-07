require 'json'

class DataFudger

  attr_reader :fudged_data
  attr_reader :origin_data

  def initialize(origin_data, fudger_spec)
    @fudged_data = Array.new
    @origin_data = origin_data
    @fudger_spec = fudger_spec
    @end = false
    @message = ""
    @code = 0
    @depth = Array.new
  end


  def run(input = @origin_data)
    input.each do |key, value|

      case value.class.to_s
      when 'Hash'
        dostuff(key)
        @depth << key
        run(value)
      when 'String'
        dostuff(key)
      end
    end

  end

  def dostuff(key)

    case @depth.size

    when 0
      m = Marshal.load(Marshal.dump(@origin_data))
      snowflake(m)
      m.delete(key)
      if(@fudger_spec[key]['restrictions']['required'])
        @fudged_data << {"status" => 400, "message"=> "#{key} is a required field", "body" => m}
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

    when 1
      m = Marshal.load(Marshal.dump(@origin_data))
      snowflake(m)
      m[@depth[0]].delete(key)
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

    when 2
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

  def magic()
    m = Marshal.load(Marshal.dump(@origin_data))
    snowflake(m)
  end

  def snowflake(m, i = @fudged_data.size, fudger_spec = @fudger_spec)
    m.each do | key, value|
      if(value.class.to_s == 'Hash')
        m[key] = snowflake(value, i, fudger_spec[key]['properties'])
      elsif(fudger_spec[key]['donotmodify'] == false)
        value << "#{i}"
      end
    end
  end

end
