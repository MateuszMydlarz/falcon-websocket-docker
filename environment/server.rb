#!/usr/bin/env async-service
# frozen_string_literal: true

require "socket"

# Shared environment for IPC configuration
class IPCServer < Async::Service::ContainerService
  def run(instance, evaluator)
    socket_path = evaluator.ipc_socket_path

    # Clean up any existing socket
    File.unlink(socket_path) if File.exist?(socket_path)

    # Create Unix domain socket server
    server = UNIXServer.new(socket_path)

    Console.info(self) {"IPC Server listening on #{socket_path}"}
    instance.ready!

    begin
      while true
        # Accept incoming connections
        client = server.accept
        # Console.info(self) {"Client connected"}

        # Send greeting
        # client.write("Hello World\n")
        # client.close

        response = client.readline.chomp
        Console.info(self) {"Received from client: #{response}"}

        # Console.info(self) {"Sent greeting and closed connection"}
      end
    rescue => error
      Console.error(self, error)
    ensure
      server&.close
      File.unlink(socket_path) if File.exist?(socket_path)
    end

    return server
  end
end