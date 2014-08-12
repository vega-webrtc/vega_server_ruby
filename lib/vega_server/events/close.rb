require 'vega_server/cleanable'
require 'vega_server/outgoing_messages/peer_hang_up'

module VegaServer::Events
  class Close
    include VegaServer::Cleanable

    def self.handle(websocket, event)
      new(websocket).handle
    end
  end
end
