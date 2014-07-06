require 'json'
require 'vine'

class DataFudger

  attr_reader :fudged_data
  attr_reader :origin_data

  def initialize(origin_data, fudger_spec)
    @fudged_data = Array.new
    @origin_data = origin_data
    @fudger_spec = fudger_spec
    @end = false
  end

  def run()
    k = ""

    @origin_data.each do |key,value|

      m = Marshal.load(Marshal.dump(@origin_data))
      create_uniqe(m, @fudged_data.size)

      if(set_none_unique(m, key))
        @fudged_data << {"status" => 400, "body" => m, "message" => "#{key} is not unique."}
      else
        @fudged_data << {"status" => 200, "body" => m, "message" => "#{key} should not be required to be unique."}
      end

      m = Marshal.load(Marshal.dump(@origin_data))
      create_uniqe(m, @fudged_data.size)

      if(remove_key(m, key))
        @fudged_data << {"status" => 400, "body" => m, "message" => "#{key} is not set."}
      else
        @fudged_data << {"status" => 200, "body" => m, "message" => "#{key} should not be required."}
      end

    end

    puts @origin_data
    puts @fudged_data

  end

  def create_uniqe(input, i)
    input.each do |key, value|
      if(@fudger_spec[key]['restrictions']['unique'])
        value << "__#{i}"
      end
    end
  end

  def set_none_unique(input, key)
    input[key] = @origin_data[key]
    if(@fudger_spec[key]['restrictions']['unique'])
      return true
    end
    false
  end

  def remove_key(input, key)
    input.delete(key)
    if(@fudger_spec[key]['restrictions']['required'])
      return true
    end
    false
  end

  def recurse(input, k)

    m = @fudger_spec.access(k)

    temp_hash = Hash.new
    fudged_hash = Marshal.load(Marshal.dump(input))
  end

end
