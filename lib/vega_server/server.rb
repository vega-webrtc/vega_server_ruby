require 'faye/websocket'
require 'vega_server/events'
require 'vega_server/add_event_listener'

module VegaServer
  class Server
    def call(env)
      env = adapted_env(env)

      return forbidden_response if !origin_allowed?(env)

      Faye::WebSocket.new(env, nil, { ping: 10 }).tap do |websocket|
        AddEventListener.call(:message, Events::Message, websocket)
        AddEventListener.call(:close, Events::Close, websocket)
      end.rack_response
    end

    def log(string)
    end

    private

    def forbidden_response
      Rack::Response.new([], 403)
    end

    def adapted_env(env)
      VegaServer.env_adapter.new(env)
    end

    def origin_allowed?(env)
      return true if allowed_origins.empty?

      origin = env.origin

      allowed_origins.any? do |allowed_origin|
        origin.match allowed_origin
      end
    end

    def allowed_origins
      VegaServer.allowed_origins
    end
  end
end
