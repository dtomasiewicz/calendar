module HTTP
  
  class Request
    attr_reader :method, :path, :headers, :data, :id
  
    def initialize(method, path, headers, data, id)
      @method = method
      @path = path
      @headers = headers
      @data = data
      @id = id
    end
    
    # create a request object from CGI environment variables
    def self.from_cgi(env, path_base = '')
      method = env['REQUEST_METHOD']
      path = env['REQUEST_URI'][path_base.length..-1]
      
      if i = path.index('?')
        path = path[0...i] # remove query-string
      end
      
      headers = {}
      env.each_pair do |k,v|
        if k =~ /^HTTP_/
          k = k.downcase.split('_').map{|w|w.capitalize}.join '-'
          headers[k] = v
        end
      end
      
      data = {}
      qs = method == 'GET' ? env['QUERY_STRING'] : STDIN.read
      qs.split('&').each do |var|
        k, v = var.split '=', -1
        data[self.decode k] = self.decode v
      end
      
      return Request.new method, path, headers, data, env['UNIQUE_ID']
    end
    
    private
    
    # uri-decode algorithm, since we can't use CGI packages
    def self.decode(str)
      parsed = ""
      while i = str.index('%')
        parsed += str[0...i] + str[i+1,2].to_i(16).chr
        str = str[i+3..-1]
      end
      return parsed+str
    end
    
  end
  
  
  class Response
    
    STATUSES = {
      :ok => '200 OK',
      :not_found => '404 Not Found',
      :error => '500 Internal Server Error'
      # there are more, of course
    }
    
    attr_accessor :status, :headers, :body
    
    def initialize(status = :ok, headers = {}, body = nil)
      @status = status
      @headers = headers
      @body = body
    end
    
    def json(obj)
      @headers['Content-Type'] = 'application/json'
      @body = JSON.stringify obj
    end
    
    def text(body)
      @headers['Content-Type'] = 'text/plain'
      @body = body
    end
    
    def to_cgi
      res = "Status: #{STATUSES[@status]}\n"
      
      @headers['Content-Length'] = @body.length if @body
      @headers.each_pair do |h, v|
        res += "#{h}: #{v}\n"
      end
      
      res += "\n"
      res += @body if @body
      return res
    end
    
  end
  
end