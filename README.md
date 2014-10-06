# Vega Server

Vega Server implements a server-side signaling protocol to aid in establishing
peer-to-peer connections in the browser through WebRTC. Used in conjunction
with [Vega Prime](https://github.com/davejachimiak/vega-prime) in the browser,
one should be able to easily create custom video chat applications.

Vega Server is a Rack application, before which middleware may be used.

[![Build Status](https://travis-ci.org/davejachimiak/vega_server.svg?branch=master)](https://travis-ci.org/davejachimiak/vega_server)

## Installation

Add this line to your Gemfile:

    gem 'vega_server'

And then execute:

    $ bundle

## Usage

### Example

Vega Server runs as a [Rack](https://github.com/rack/rack) app.  Here's all
that's needed in your [rackup
file](https://github.com/rack/rack/wiki/%28tutorial%29-rackup-howto) to get it
running:

```ruby
# vega_server_example.ru

require 'rack'
require 'vega_server'

run VegaServer::Server.new
```

The following would start the above example at port 4000 with the
[Puma](https://github.com/puma/puma) web server:
```shell
$ bundle exec puma ./vega_server_example.ru -p 4000
```

### Security notes

The above example isn't secure.  It allows connections from any client that has
its address.

#### Allowed origins

Whitelist client origins to ensure that only your applications get access to
your Vega Server. Use regexes for flexibility if desired.

```ruby
# example.ru

require 'vega_server'

VegaServer.configure do |config|
  config.allow_origins([/www.mycoolapp.com/, /www.myawesomeapp.com/])
end

run VegaServer::Server.new
```

The server returns a status code of 403 (Forbidden) if a request comes from an
unallowed origin per [section 10.2 of the Websocket
protocol](http://tools.ietf.org/html/rfc6455#section-10.2).

Although allowing origins is good, non-browser clients can spoof the
"HTTP-ORIGIN" header.  Extra authentication is better.

#### Authentication considerations

##### Token checking

One way to authenticate a request is to check a token included in its
parameters.  If the token is correct, continue opening the Websocket
connection.  If it isn't, return a status code of 401 (Unauthorized).

With Rack, you can write
[middleware](http://www.amberbit.com/blog/2011/07/13/introduction-to-rack-middleware/)
that checks such a token.  If the token matches, continue running the app.  If
not, short-circuit the app and return a response.

```ruby
# example.ru

require 'vega_server'

class TokenAuthorizer
  TOKEN = 'secret'.freeze

  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    token   = request.params['token']

    if token == TOKEN
      @app.call(env) 
    else
      unauthorized_response
    end
  end

  private

  def unauthorized_response
    Rack::Response.new([], 401)
  end
end

use TokenAuthorizer
run VegaServer::Server.new
```

If you ran your the above code locally on port 4500 and started Vega Prime in
the browser with a url of `ws://localhost:4500/?token=secret`, you'd get a
successful, persistent connection. Requesting with a different token would
return a 401 response.

#### SSL

You can achieve SSL security by using the `wss` scheme in the url you pass to
Vega Prime and configuring your web server properly.  See the documentation for
the Ruby web server you're using for information on how to register your SSL
cert and key.

### Running with Ruby web servers (Puma, Thin, Passenger, etc.)

Vega Server can be served with any web server that is supported by [Faye
Websocket](https://github.com/faye/faye-websocket-ruby).  See Faye Websocket's
documentation for instructions on how to use specific web servers it.
Specifically, it may require an adapter to be loaded. Faye Websocket requires
an adapter to be loaded for the Thin web server, for example.

```ruby
# example.ru
require 'vega_server'

Faye::WebSocket.load_adapter('thin')

run VegaServer::Server.new
```

You should load adapters in this fashion if you want to use
a server that requires it. 

## To Do

* create delegation mechanism to load faye adapters
* create levels of logging
* create storage adapter for Redis
* design for extension of base protocol (mute peers, etc.)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
