module VegaServer::OutgoingMessages
  class CallAccepted
    include ClientMessageable

    def initialize(peers)
      @peers = peers
    end

    def type
      'callAccepted'
    end

    def payload
      { peers: @peers }
    end
  end
end
