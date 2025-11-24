# #!/usr/bin/env async-service
# # frozen_string_literal: true
#
# # Released under the MIT License.
# # Copyright, 2025, by Samuel Williams.
#
# require "socket"
# require "async"
# require "async/service/container_service"
# require "async/service/container_environment"
# require_relative '../environment/client'
# require_relative '../environment/server'
#
#
# # Define both services using the shared IPC environment:
# service "ipc-server" do
#   service_class IPCServer
#   include IPCEnvironment
# end
#
# service "ipc-client" do
#   service_class IPCClient
#   include IPCEnvironment
# end