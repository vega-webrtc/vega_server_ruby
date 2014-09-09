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
