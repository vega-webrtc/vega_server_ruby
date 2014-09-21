require 'vega_server/version'
require 'vega_server/json'
require 'vega_server/server'
require 'vega_server/adapters'
require 'vega_server/storage'
require 'vega_server/connection_pool'
require 'vega_server/incoming_messages/call_middlewares'

module VegaServer
  def self.configure
    yield(self)
  end

  def self.set_call_middlewares(middlewares)
    @call_middlewares = call_middlewares.add middlewares
  end

  def self.call_middlewares
    @call_middlewares ||=
      VegaServer::IncomingMessages::CallMiddlewares.
        new(default_middlewares)
  end

  def self.reset_call_middlewares!
    @call_middlewares =
      VegaServer::IncomingMessages::CallMiddlewares.
        new(default_middlewares)
  end

  def self.default_middlewares
    VegaServer::IncomingMessages::CallMiddlewares::DEFAULT
  end

  def self.allow_origins(origins)
    @allowed_origins = origins
  end

  def self.allowed_origins
    @allowed_origins ||= []
  end

  def self.storage
    @storage ||= VegaServer::Storage::Memory
  end

  def self.env_adapter
    @env_adapter ||= VegaServer::Adapters::Env
  end

  def self.enable_modified_env!
    @env_adapter = VegaServer::Adapters::ModifiedEnv
  end

  def self.disable_modified_env!
    @env_adapter = VegaServer::Adapters::Env
  end

  def self.connection_pool
    VegaServer::ConnectionPool
  end
end
