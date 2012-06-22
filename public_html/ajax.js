var PATH_BASE = '/~umtomasi/calendar/';

function queryString(data) {
  vals = [];
  for(name in data) {
    if(data[name] !== undefined && data[name] !== null) {
      vals.push(encodeURIComponent(name)+'='+encodeURIComponent(data[name]));
    }
  }
  return vals.join('&');
}

function get(url, data, success) {
  var xhr = new XMLHttpRequest();
  xhr.open('GET', PATH_BASE+url+'?'+queryString(data), true);
  xhr.onreadystatechange = function() {
    if(xhr.readyState == 4) {
      success(JSON.parse(xhr.responseText));
    }
  }
  xhr.send(null);
}

function post(url, data, success) {
  data = queryString(data);
  var xhr = new XMLHttpRequest();
  xhr.open('POST', PATH_BASE+url, true);
  xhr.onreadystatechange = function() {
    if(xhr.readyState == 4) {
      success(JSON.parse(xhr.responseText));
    }
  }
  xhr.send(data);
}