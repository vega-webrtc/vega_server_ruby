module VegaServer
  class ForbiddenResponse
    def respond
      Rack::Response.new([], 403)
    end
  end
end
