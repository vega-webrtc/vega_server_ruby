module VegaServer::IncomingMessages
  class Answer
    include Relayable

    def read_relayable
      payload[:answer]
    end

    def outgoing_message_class
      VegaServer::OutgoingMessages::Answer
    end
  end
end
