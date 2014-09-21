module VegaServer::IncomingMessages::CallResponse
  class Accept
    include VegaServer::Storageable

    attr_reader :client_caller

    def initialize(client_caller)
      @client_caller = client_caller
    end

    def bind
      yield client_caller
    end

    def handle
      add_client_to_storage
      VegaServer::OutgoingMessages.send_message(websocket, message)
    end

    private

    def add_client_to_storage
      storage.add!(client_id, payload)
    end

    def client_id
      client_caller.client_id
    end

    def payload
      client_caller.payload
    end

    def websocket
      client_caller.websocket
    end

    def message
      VegaServer::OutgoingMessages::CallAccepted.new(peers)
    end

    def peers
      room.reject do |client|
        client[:client_id] == client_id
      end.map do |peer|
        peer.tap { |p| p[:peerId] = p.delete(:client_id) }
      end
    end

    def room
      storage.room(room_id)
    end

    def room_id
      client_caller.room_id
    end
  end
end
