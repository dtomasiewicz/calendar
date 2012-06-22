#!/usr/bin/ruby

# hacks to support Ruby 1.8.7
unless Kernel.respond_to?(:require_relative)
  # require_relative introduced in 1.9.2
  module Kernel
    def require_relative(path)
      require File.join(File.dirname(caller[0]), path.to_str)
    end
  end
  class String
    alias :old_caccess :[]
    def [](i, *args)
      if i.kind_of?(Integer) && args.length == 0
        return old_caccess(i, 1)
      else
        return old_caccess(i, *args)
      end
    end
  end
end

require_relative '../../calendar/http'

begin
  require_relative '../../calendar/handlers'
  response = dispatch HTTP::Request.from_cgi(ENV, '/~umtomasi/calendar')
rescue => e
  response = HTTP::Response.new :error
  response.text "#{e.message}\n#{e.backtrace}\n"
end

puts response.to_cgi
