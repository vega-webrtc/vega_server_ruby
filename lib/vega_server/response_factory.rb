require 'vega_server/upgrade_response'
require 'vega_server/forbidden_response'

module VegaServer
  class ResponseFactory
    def self.create(env)
      if origin_allowed?(env)
        VegaServer::UpgradeResponse.new(env)
      else
        VegaServer::ForbiddenResponse.new
      end
    end

    def self.origin_allowed?(env)
      allowed_origins = VegaServer.allowed_origins

      return true if allowed_origins.empty?

      origin = env.origin

      allowed_origins.any? do |allowed_origin|
        origin.match allowed_origin
      end
    end
    private_class_method :origin_allowed?
  end
end
