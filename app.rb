# app.rb
require 'async'
require 'falcon'
require 'console'
require 'console/output/split'
require 'async/redis'


class MyRackApp
  def call(env)
    [
      200,
      {"Content-Type" => "text/plain"},
      ["#{Time.now}"]
    ]
  end
end
