require 'vega_server'

VegaServer.configure do |config|
  config.allow_origins [/www.poop.com/]
end

run VegaServer::Server.new
