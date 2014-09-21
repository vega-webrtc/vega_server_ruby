require 'vega_server/outgoing_messages/client_messageable'

require 'vega_server/outgoing_messages/offer'
require 'vega_server/outgoing_messages/answer'
require 'vega_server/outgoing_messages/candidate'
require 'vega_server/outgoing_messages/peer_hang_up'
require 'vega_server/outgoing_messages/call_accepted'
require 'vega_server/outgoing_messages/call_rejected'

module VegaServer
  module OutgoingMessages
    def self.send_message(websocket, message)
      websocket.send(message.as_json)
    end
  end
end
