require 'async/websocket/adapters/rack'
require 'set'

$connections = Set.new

LAMB = lambda {|env|
  Async::WebSocket::Adapters::Rack.open(env, protocols: ['ws']) do |connection|
    $connections << connection

    while message = connection.read
      $connections.each do |connection|
        connection.write(message)
        connection.flush
      end
    end
  ensure
    $connections.delete(connection)
  end or [200, {}, ["Hello Websocket"]]
}