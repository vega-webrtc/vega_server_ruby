class VegaServer::IncomingMessages::CallMiddlewares
  class CheckRoomId
    ERROR_MESSAGE = 'Call must include a roomId.'.freeze

    def call(client_caller)
      if client_caller.room_id
        client_caller.accept_response
      else
        client_caller.reject_response(ERROR_MESSAGE)
      end
    end
  end
end
