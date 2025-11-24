#!/usr/bin/env -S falcon host
# frozen_string_literal: true
require_relative 'app'
require 'async/redis'

load :rack, :supervisor

service 'localhost' do
  include Falcon::Environment::Rack
  endpoint {Async::HTTP::Endpoint.parse('http://0.0.0.0:8013')}
end

class MyService < Async::Service::Generic
  def setup(container)
    puts 2
    container.spawn do |instance|
      evaluator = @environment.evaluator
      Console.info(self, "Connecting to Redis at", evaluator.redis_endpoint)

      Async do
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
      end
    end
  end
end

service "myservice" do
  puts 3
  service_class MyService
  redis_endpoint {Async::Redis::Endpoint.local}
end