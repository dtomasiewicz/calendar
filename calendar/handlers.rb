require 'date'
require_relative 'dispatch'


respond_to '/users' do |req, res, db|
  # sorted list of unique user names
  users = db['events'].values.map{|e|e['user']}.uniq.sort
  # return as objects
  res.json({'users'=>users.map{|name|{'name'=>name}}})
end


respond_to '/events' do |req, res, db|
  events = db['events'].values
  if req.data['user']
    # if a user is provided, filter by user
    events = events.select do |event|
      event['user'] == req.data['user']
    end
  end
  # order by date
  events.sort! do |a, b|
    a['date'] <=> b['date']
  end
  res.json({'events'=>events})
end


respond_to '/events/add', 'POST' do |req, res, db|
  success = false
  
  # validate form data... sort of
  user = req.data['user']
  begin
    date = DateTime.parse(req.data['date'])
  rescue
    date = DateTime.now
  end
  
  if user.length > 0
    # auto-incrementing ID
    id = db['events_next_id']
    db['events_next_id'] += 1
    db['events'][id] = {
      'id' => id.to_s,
      'date' => date.strftime('%Y-%m-%d %H:%M:%S'),
      'name' => req.data['name'] || '',
      'desc' => req.data['desc'] || '',
      'user' => user
    }
    success = true
  end
  
  res.json({'success'=>success})
end

respond_to '/events/delete', 'POST' do |req, res, db|
  success = false
  id = req.data['event']
  if db['events'][id]
    db['events'].delete req.data['event']
    success = true
  end
  res.json({'success'=>success})
end
