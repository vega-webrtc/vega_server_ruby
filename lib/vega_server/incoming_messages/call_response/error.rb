module VegaServer::IncomingMessages::CallResponse
  class Error
    attr_reader :websocket, :message

    def initialize(websocket, message)
      @websocket = websocket
      @message = message
    end
  end
end
