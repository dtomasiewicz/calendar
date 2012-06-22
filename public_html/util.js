function clear(el) {
  while(el.childNodes.length > 0) {
    el.removeChild(el.childNodes[0]);
  }
}

function formData(form) {
  var data = {}
  for(var i = 0; i < form.elements.length; i++) {
    if(form.elements[i].name) {
      data[form.elements[i].name] = form.elements[i].value;
    }
  }
  return data
}

function clearForm(form) {
  for(var i = 0; i < form.elements.length; i++) {
    if(form.elements[i].name) {
      form.elements[i].value = '';
    }
  }
}

function setCookie(name, value, days) {
  var today = new Date();
  var expire = new Date();
  if(value == null || value == undefined) {
    // delete cookie
    expire.setTime(today.getTime()-1);
  } else {
    // set cookie
    expire.setTime(today.getTime()+3600000*24*days);
  }
  document.cookie = name+'='+escape(value)+";expires="+expire.toGMTString();
}

function getCookie(name) {
  var theCookie = " "+document.cookie;
  var ind = theCookie.indexOf(" "+name+"=");
  if(ind == -1) ind = theCookie.indexOf(";"+name+"=");
  if(ind == -1 || name == "") return undefined;
  var ind1 = theCookie.indexOf(";", ind+1);
  if(ind1 == -1) ind1 = theCookie.length; 
  return unescape(theCookie.substring(ind+name.length+2, ind1));
}