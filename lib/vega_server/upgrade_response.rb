require 'faye/websocket'
require 'vega_server/events'
require 'vega_server/add_event_listener'

module VegaServer
  class UpgradeResponse
    def initialize(env)
      @env = env
    end

    def respond
      Faye::WebSocket.new(@env, nil, { ping: 10 }).tap do |websocket|
        AddEventListener.call(:message, Events::Message, websocket)
        AddEventListener.call(:close, Events::Close, websocket)
      end.rack_response
    end
  end
end
