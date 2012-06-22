function Calendar(users, events, form) {
  var that = this;
  this.users = document.getElementById(users);
  this.events = document.getElementById(events);
  this.form = document.getElementById(form);
  
  this.selectedUser = function() {
    return this.users.options[this.users.selectedIndex].value || null;
  };
  
  // loads the list of users. if a loaded user has a name matching the value
  // of "selected", it is selected automatically. the events for the selected
  // user (or otherwise all users) are then loaded. this ensures proper event
  // loading even if the passed-in user no longer exists.
  this.loadUsers = function(selected) {
    get('users', {}, function(data) {
      clear(that.users);
      // add blank option
      var exists = false;
      that.users.appendChild(document.createElement('option'));
      for(var i = 0; i < data['users'].length; i++) {
        var user = data['users'][i];
        var opt = document.createElement('option');
        opt.appendChild(document.createTextNode(user.name));
        that.users.appendChild(opt);
        if(user.name == selected) {
          opt.selected = true;
          exists = true;
        }
      }
      setCookie('selectedUser', exists ? selected : null, 365);
      that.loadEvents(that.selectedUser());
    });
  };
  
  // creates a DOM element for the given event and appends it to the list
  this._appendEvent = function(event) {
    
    var del = document.createElement('button');
    del.appendChild(document.createTextNode('X'));
    del.value = event.id;
    
    var name = document.createElement('h3');
    name.appendChild(document.createTextNode(event.name+' '));
    name.appendChild(del);
    
    var desc = document.createElement('p');
    desc.appendChild(document.createTextNode(event.desc));
    desc.className = 'desc';
    
    var date = document.createElement('p');
    date.appendChild(document.createTextNode(event.date));
    date.className = 'date';
    
    var li = document.createElement('li');
    li.appendChild(name);
    li.appendChild(desc);
    li.appendChild(date);
    
    this.events.appendChild(li);
    
    // apply delete handler
    del.onclick = function() {
      post('events/delete', {'event':event.id}, function(res) {
        if(res.success) {
          // reload whole user list, since deleting a user's last event may
          // result in deletion of the user as well
          that.loadUsers(that.selectedUser());
        }
      });
    };
  }
  
  this.loadEvents = function(user) {
    get('events', {'user':user}, function(data) {
      clear(that.events);
      for(var i = 0; i < data['events'].length; i++) {
        // create the list item for the event
        that._appendEvent(data['events'][i]);
      }
    });
  };
  
  // INITIALIZE
  this.loadUsers(getCookie('selectedUser'));
  
  // user selection listener
  this.users.onchange = function() {
    var user = that.selectedUser();
    that.loadEvents(user);
    setCookie('selectedUser', user, 365);
  };
  
  // create the "add event" button
  this.add = document.createElement('button');
  this.add.appendChild(document.createTextNode('add an event'));
  this.users.parentNode.insertBefore(this.add, this.users.nextSibling);
  this.add.onclick = function() {
    that.form.elements['user'].value = that.selectedUser();
    that.form.style.display = 'block';
  };
  
  // ajax form submission
  this.form.onsubmit = function() {
    var data = formData(this);
    post('events/add', data, function(res) {
      if(res.success) {
        clearForm(that.form);
        that.form.style.display = 'none';
        that.loadUsers(data['user']);
      } else {
        alert('Error: you must provide a user name.');
      }
    });
    return false;
  };
}
