module VegaServer::OutgoingMessages
  class CallRejected
    include ClientMessageable

    def initialize(error)
      @error = error
    end

    def type
      'callRejected'
    end

    def payload
      { error: @error }
    end
  end
end
