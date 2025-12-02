# app.rb
require 'async'
require 'falcon'
require 'console'
require 'console/output/split'
# require 'async/redis'
require 'async/websocket/adapters/rack'
require 'set'


# app/web_socket_app.rb
require "json"

class WebSocketApp
  def initialize
    @clients = Set.new
  end

  def call(env)
    if Async::WebSocket::Adapters::Rack.websocket?(env)
      handle_websocket(env)
    else
      serve_index
    end
  end

  private

  def handle_websocket(env)
    Async::WebSocket::Adapters::Rack.open(env) do |socket|
      @clients.add(socket)
      broadcast(type: "info", text: "Client joined (#{@clients.size})")

      begin
        while message = socket.read
          broadcast(
            type: "message",
            text: message,
            time: Time.now.iso8601
          )
        end
      ensure
        @clients.delete(socket)
        broadcast(type: "info", text: "Client left (#{@clients.size})")
      end
    end
  end

  def broadcast(data)
    json = JSON.dump(data)
    @clients.each do |client|
      begin
        client.write(json)
      rescue
        # ignore client write failures
      end
    end
  end

  def serve_index
    [
      200,
      {"Content-Type" => "text/plain"},
      ["#{Time.now}"]
    ]
  end
end


