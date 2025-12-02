# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require "socket"
require "async"
require 'falcon'
require 'console'
require 'console/output/split'
require 'async/redis'

require "async/service/container_service"
require "async/service/container_environment"

require_relative './environment/client'
require_relative './environment/server'
require_relative './environment/redis'

# Server service that listens on a Unix domain socket and responds with "Hello World"


load :rack, :supervisor

module IPCEnvironment
  include Async::Service::ContainerEnvironment

  def ipc_socket_path
    File.expand_path("service.ipc", Dir.pwd)
  end

  def ipc_connection_timeout
    5.0
  end

  # Override to use only 1 instance for both services.
  def count
    1
  end
end

# Define both services using the shared IPC environment:
service "ipc-server" do
  service_class IPCServer
  include IPCEnvironment
end

# service "ipc-client" do
#   service_class IPCClient
#   include IPCEnvironment
# end

service "redis-client" do
  service_class IPCRedisListener
  include IPCEnvironment
  redis_endpoint {Async::Redis::Endpoint.local}
end

service 'localhost' do
  include Falcon::Environment::Rack
  endpoint {Async::HTTP::Endpoint.parse('http://0.0.0.0:8013')}
end