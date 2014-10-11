class VegaServer::IncomingMessages::CallMiddlewares
  class CheckRoomId
    ERROR_MESSAGE = 'Call must include a roomId.'.freeze

    def initialize(client_caller)
      @client_caller = client_caller
    end

    def call
      if room_id?
        accept_response
      else
        reject_response
      end
    end

    private

    attr_reader :client_caller

    def room_id?
      !!client_caller.room_id
    end

    def accept_response
      client_caller.accept_response
    end

    def reject_response
      client_caller.reject_response(ERROR_MESSAGE)
    end
  end
end
