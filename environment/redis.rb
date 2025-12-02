#!/usr/bin/env async-service
# frozen_string_literal: true


require "socket"

# Shared environment for IPC configuration
class IPCRedisListener < Async::Service::ContainerService
  def setup(container)
    super
    container.run(count: 1, restart: true) do |instance|
    socket_path = File.expand_path("service.ipc", Dir.pwd)
    # socket_path = evaluator.ipc_socket_path
    # timeout = evaluator.ipc_connection_timeout

    # Console.info(self) {"IPCRedisListener starting - will connect to #{socket_path}"}
    instance.ready!

    url = "redis://:yourpassword@redis-server:6379/1"
    uri = Async::Redis::Endpoint.parse(url)
    client = Async::Redis::Client.new(uri)

    Async do |task|
      while true
        begin

          client.subscribe 'status' do |context|
            while response = context.listen
              puts response.inspect
              Console.info(self, "Received event from Redis:", response)
              ipc_client = UNIXSocket.new(socket_path)
              ipc_client.write(response)
              ipc_client.close
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
end
