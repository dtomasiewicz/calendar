COMP 3010 Assignment 3
Daniel Tomasiewicz (7613946)

The live version of my assignment can be accessed at:

  http://www3.cs.umanitoba.ca/~umtomasi/


## Client Side Details ##

The client-side component of my calendar consists of an index.html file and 
several JavaScript files, which together provide an interface through which 
the user can create and execute dynamic content requests using an XMLHttpRequest
object. JSON responses are then parsed by JavaScript and the DOM is updated 
accordingly. Any sorting/filtering of data is handled by the server.

I also use JavaScript exclusively for Cookie management, since the server is
not really interested in which user was last selected (all service requests are
completely stateless).


## Server Side Details ##

I decided to implement the server-side component of my event calendar as a 
REST service, using Apache's mod_rewrite to provide resource transparency by 
hiding not only the language of implementation, but the server implementation 
itself (Apache + CGI).

public_html/cgi-bin/calendar.rb

  - serves as the single point of entry for all dynamic content requests
    - ensures that users are not able to execute just any server script at will 
      (it is the only script located inside the public root)
  - provides an abstraction to the rest of the application, in that it specifies 
    the translation of CGI variables to a more generic Request object used by the 
    application logic, then specifies the translation of a returned Response 
    object into CGI output
    - e.g. the Status header is a CGI implementation detail, not an HTTP header
    - allows us to port our code away from CGI in the future if necessary-- for 
      example, to a persistent implementation that maintains the database and 
      application code in memory to reduce startup overhead

calendar/handlers.rb

  - business logic for the available "actions" a user can perform, which are 
    associated with a particular request method and path

calendar/dispatch.rb

  - methods for defining and dispatching (executing) user actions

calendar/http.rb

  - the Request and Response classes

calendar/json.rb

  - functions for parsing and stringifying between JSON text and Ruby data 
    structures.


## Data Persistence Notes ##

Since I needed to write a JSON stringifier, I figured I might as well write a
parser and use JSON as a basic key-value store for persisting my data. While
a domain-specific line-based format might have been easier to implement (since
we couldn't use existing JSON libraries), it would not be as easy to extend for
storage of non-event data when necessary-- and in the real world, our libraries
wouldn't be limited anyways!

The actual implementation is pretty simple-- calendar/database.json holds a 
serialized JSON object which is loaded and written at the beginning and end of
each request. One deficiency of this method is that if two users update the
database concurrently, only the last update will stick. If we needed to support
concurrency, we would need to consider file locks or the use of a single data 
service process (like an actual DBMS).
