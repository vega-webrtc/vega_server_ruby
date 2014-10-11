require 'vega_server/incoming_messages/call_middlewares/check_room_id'

module VegaServer::IncomingMessages
  class CallMiddlewares
    include Enumerable

    DEFAULT = [CheckRoomId].freeze

    def initialize(middlewares)
      @middlewares = middlewares
    end

    def each
      middlewares.each do |middleware|
        yield middleware
      end
    end

    def add(more_middlewares)
      self.class.new(middlewares + more_middlewares)
    end

    def run(client_caller)
      initial_response = initial_response(client_caller)

      inject(initial_response) do |acc, middleware|
        acc.bind { |client_caller| middleware.new(client_caller).call }
      end
    end

    private

    def initial_response(client_caller)
      VegaServer::IncomingMessages::CallResponse::Accept.new(client_caller)
    end

    attr_reader :middlewares
  end
end
