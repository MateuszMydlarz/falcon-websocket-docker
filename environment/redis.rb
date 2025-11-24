#!/usr/bin/env async-service
# frozen_string_literal: true


require "socket"

# Shared environment for IPC configuration
class IPCRedisListener < Async::Service::ContainerService
  def run(instance, evaluator)
    socket_path = evaluator.ipc_socket_path
    timeout = evaluator.ipc_connection_timeout

    Console.info(self) {"IPCRedisListener starting - will connect to #{socket_path}"}
    instance.ready!

    Async do |task|
      while true
        begin
          # Wait a bit before first connection attempt
          # task.sleep(2)

          url = "redis://:yourpassword@redis-server:6379/1"
          uri = Async::Redis::Endpoint.parse(url)
          client = Async::Redis::Client.new(uri)

          instance.ready!

          client.subscribe 'status' do |context|
            Console.info(self, "Subscribed to Redis channel 'status'.")
            while response = context.listen
              Console.info(self, "Received event:", response)
            end
          end

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
