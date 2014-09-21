class VegaServer::IncomingMessages::CallMiddlewares
  class CheckRoomId
    ERROR_MESSAGE = 'Call must include a roomId.'.freeze

    def call(client_caller)
      if !client_caller.room_id
        error = VegaServer::IncomingMessages::CallResponse::Error.new(
          client_caller.websocket,
          ERROR_MESSAGE
        )

        VegaServer::IncomingMessages::CallResponse::Reject.new(error)
      else
        VegaServer::IncomingMessages::CallResponse::Accept.new(client_caller)
      end
    end
  end
end
