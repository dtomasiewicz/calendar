require_relative 'json'
require_relative 'http'


DATA_FILE = File.join File.dirname(__FILE__), 'database.json'
HANDLERS = {}


# registers an action handler, associated with a request path/method
def respond_to(action, method = 'GET', &block)
  HANDLERS[method] ||= {}
  HANDLERS[method][action] = block
end


# executes a request, returns the response
def dispatch(request)
  action = HANDLERS[request.method] ? HANDLERS[request.method][request.path] : nil
  
  if action
    response = HTTP::Response.new
    data = nil
    
    # load the database
    File.open(DATA_FILE, 'r') do |f|
      data = JSON.parse f.read
    end
    
    # handle the request
    action.call request, response, data
    
    # write the database (to temp file then rename, for atomicity)
    tmpfile = DATA_FILE+request.id
    File.open(tmpfile, 'w') do |f|
      f.write JSON.stringify(data)
    end
    File.rename(tmpfile, DATA_FILE)
  else
    response = HTTP::Response.new :not_found
  end
  
  return response
end

