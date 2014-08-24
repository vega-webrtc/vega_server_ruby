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
      add_client_to_storage
      VegaServer::OutgoingMessages.send_message(@websocket, message)
    end

    private

    def message
      VegaServer::OutgoingMessages::CallAccepted.new(peers)
    end

    def peers
      room.reject do |client|
        client[:client_id] == @client_id
      end.map do |peer|
        peer.tap { |p| p[:peerId] = p.delete(:client_id) }
      end
    end

    def room
      storage.room(@room_id)
    end

    def add_client_to_storage
      storage.add!(@client_id, @payload)
    end
  end
end
