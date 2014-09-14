require 'vega_server'

VegaServer.configure do |config|
  config.allow_origins [/example.com/]
end

run VegaServer::Server.new
