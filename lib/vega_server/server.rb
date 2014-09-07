require 'vega_server/response_factory'

module VegaServer
  class Server
    def call(env)
      env = adapted_env(env)

      VegaServer::ResponseFactory.create(env).respond
    end

    def log(string)
    end

    private

    def adapted_env(env)
      VegaServer.env_adapter.new(env)
    end
  end
end
