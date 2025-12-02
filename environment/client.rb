#!/usr/bin/env async-service
# frozen_string_literal: true


require "socket"

# Shared environment for IPC configuration
class IPCClient < Async::Service::ContainerService
  def run(instance, evaluator)
    socket_path = evaluator.ipc_socket_path
    timeout = evaluator.ipc_connection_timeout

    Console.info(self) {"IPC Client starting - will connect to #{socket_path}"}
    instance.ready!

    Async do |task|
      while true
        begin
          # Wait a bit before first connection attempt
          task.sleep(2)
          client = UNIXSocket.new(socket_path)
          client.write("Hello World\n")
          client.close
          task.sleep(3)

        rescue Errno::ENOENT
          Console.warn(self) {"Server socket not found at #{socket_path}, retrying..."}
          task.sleep(2)
        rescue => error
          Console.error(self, error)
          task.sleep(2)
        end
      end
    end
  end
end
