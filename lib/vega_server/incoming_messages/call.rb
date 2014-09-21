module VegaServer::IncomingMessages
  class Call
    include VegaServer::Storageable

    def initialize(websocket, payload)
      client_id = pool.add!(websocket)

      @client_caller = VegaServer::IncomingMessages::CallResponse::ClientCaller.new(
        websocket,
        payload,
        client_id
      )
    end

    def handle
      run_middlewares.handle
    end

    private

    attr_reader :client_caller

    def run_middlewares
      call_middlewares.run(client_caller)
    end

    def call_middlewares
      VegaServer.call_middlewares
    end
  end
end
