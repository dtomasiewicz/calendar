# simple recursive descent JSON parser/stringifier
module JSON
  
  RE_INT = /^(-?\d+)($|[^\d])/
  RE_FLOAT = /^(-?\d+)?(\.\d+)(e[+-]?\d+)?($|[^\d])/i
  
  # @return object
  def self.parse(str)
    return self.parse_object(str)[1]
  end
  
  # @return newStr, object
  def self.parse_object(str)
    if str[0] == '{'
      obj = {}
      str = str[1..-1]
      while str[0] == '"'
        str, key, value = self.parse_pair str
        obj[key] = value
        if str[0] == ','
          str = str[1..-1]
        else
          break
        end
      end
      if str[0] == '}'
        return str[1..-1], obj
      else
        raise "Unexpected #{str[0]}, expecting }"
      end
    else
      raise "Unexpected #{str[0]}, expecting {"
    end
  end
  
  # @return newStr, key, value
  def self.parse_pair(str)
    str, key = self.parse_string str
    if str[0] == ':'
      str = str[1..-1]
    else
      raise "Unexpected #{str[0]}, expecting :"
    end
    str, value = self.parse_value str
    return str, key, value
  end
  
  # @return newStr, value
  def self.parse_value(str)
    case str[0]
    when '"'; return self.parse_string str
    when '{'; return self.parse_object str
    when '['; return self.parse_array str
    else
      case str
      when /(\d|\.)/; return self.parse_number str
      when /^true/i; return str[4..-1], true
      when /^false/i; return str[5..-1], false
      when /^null/i; return str[4..-1], nil
      else raise "Unexpected #{str[0]}, expecting value" end
    end
  end
  
  # @return newStr, string
  def self.parse_string(str)
    if str[0] == '"'
      esc = false
      i = 1
      while esc || str[i] != '"'
        esc = str[i] == '\\' ? !esc : false
        i += 1
      end
      return str[i+1..-1], str[1...i].gsub('\"', '"')
    else
      raise "Unexpected #{str[0]}, expecting string"
    end
  end
  
  # @return newStr, array
  def self.parse_array(str)
    if str[0] == '['
      str = str[1..-1]
      ary = []
      while str[0] != ']'
        str, val = self.parse_value str
        ary << val
        if str[0] == ','
          str = str[1..-1]
        else
          break
        end
      end
      if str[0] == ']'
        return str[1..-1], ary
      else
        raise "Unexpected #{str[0]}, expecting ]"
      end
    else
      raise "Unexpected #{str[0]}, expecting array"
    end
  end
  
  # @return newStr, number
  def self.parse_number(str)
    if m = str.match(RE_FLOAT)
      mstr = m[1..3].join
      return str[mstr.length..-1], mstr.to_f
    elsif m = str.match(RE_INT)
      mstr = m[1]
      return str[mstr.length..-1], mstr.to_i
    else
      raise "Unexpected #{str[0]}, expecting number"
    end
  end
  
  # @return string
  def self.stringify(obj)
    case obj
    when nil; return "null"
    when true; return "true"
    when false; return "false"
    when String; return '"'+obj.gsub('"', '\"')+'"'
    when Float, Integer; return obj.to_s
    when Hash
      entries = []
      obj.each_pair{|k,v|entries<<"#{self.stringify k.to_s}:#{self.stringify v}"}
      return "{#{entries.join ','}}"
    when Array
        return '['+obj.map{|i|self.stringify i}.join(',')+']'
    else return self.stringify(obj.to_s) end
  end
  
end
