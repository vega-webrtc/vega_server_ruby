module VegaServer::IncomingMessages::CallResponse
  class ClientCaller
    attr_reader :websocket, :payload, :client_id

    def initialize(websocket, payload, client_id)
      @websocket = websocket
      @payload = payload
      @client_id = client_id
    end

    def room_id
      payload[:room_id]
    end

    def badge
      payload[:badge]
    end
  end
end
