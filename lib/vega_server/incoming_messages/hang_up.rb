module VegaServer::IncomingMessages
  class HangUp
    include VegaServer::Cleanable

    def after_remove_client
      websocket.close
    end
  end
end
