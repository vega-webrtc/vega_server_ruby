module VegaServer::IncomingMessages::CallResponse
  class Reject
    def initialize(error)
      @error = error
    end

    def bind
      self
    end

    def handle
      VegaServer::OutgoingMessages.send_message(websocket, message)
    end

    private

    attr_reader :error

    def message
      VegaServer::OutgoingMessages::CallRejected.new(error_message)
    end

    def websocket
      error.websocket
    end

    def error_message
      error.message
    end
  end
end
