module VegaServer::IncomingMessages
  class Call
    include VegaServer::Storageable

    def initialize(websocket, payload)
      @websocket = websocket
      @payload   = payload
      @room_id   = payload[:room_id]
      @client_id = pool.add!(@websocket)
    end

    def handle
      return unless @room_id
      VegaServer::OutgoingMessages.send_message(@websocket, message)
      add_client_to_room
    end

    private

    def message
      VegaServer::OutgoingMessages::CallAccepted.new(peers)
    end

    def peers
      peer_ids.map do |peer_id|
        peer  = storage.client(peer_id)
        badge = peer[:badge] || {}

        { peer_id: peer_id, badge: badge }
      end
    end

    def peer_ids
      room.reject { |client_id| client_id == @client_id }
    end

    def room
      @room ||= storage.room(@room_id)
    end

    def add_client_to_room
      storage.add_to_room(@client_id, @payload)
    end
  end
end
