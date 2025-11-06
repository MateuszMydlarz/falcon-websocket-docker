# app.rb
require 'async'
require 'falcon'
require 'console'
require 'console/output/split'
require 'async/redis'

# Background async tasks (to be started by Falcon services)
def start_task1(task, background, shared_data, queue)
  url = "redis://:yourpassword@redis-server:6379/1"
  uri = Async::Redis::Endpoint.parse(url)
  client = Async::Redis::Client.new(uri)

  Thread.new do
    $mutex.synchronize do
    Async do |task|
      task.async do |subtask|
        client.subscribe 'frontend' do |context|
          while event = context.listen
            background.increment_task1
            shared_data << rand(100)
            queue.enque
            STDOUT.flush
            puts shared_data
            pp background.task1_value
            pp event
          end
        end
      end
    end
  end
end

  # # thread = Thread.new do
  # #   reactor.async do
  #     # numbers = 4.times.map{rand(10)}
  #     # sorted = []
  #     # Sleep sort the numbers:
  #     # numbers.each do |number|
  #     #   STDOUT.flush
  #     #   puts number
  #     #   sorted << number
  #     #   puts "TASK VALUE1: #{$background_state.get_value1}"
  #     #   puts "TASK VALUE1: #{$background_state.task1_value}"
  #     #   $background_state.increment_task1
  #       reactor.interrupt
  #       # sleep 2
  #     # end
  #   # end
  #   # reactor.run
  # # end
  #   thread.join

end

  # SemanticLogger.flush
  # terminal = Console::Output::Terminal.new(STDERR)
  # serialized = Console::Output::Serialized.new(File.open("log.json", "a"))
  # Console.logger = Console::Logger.new(Console::Output::Split[terminal, serialized])
  #
  # puts '123'
  # # Async do |task|
  # Thread.new do
  #   Async do |task|
  #   task.async do
  #   numbers = 4.times.map{rand(10)}
  #   sorted = []
  #   # Sleep sort the numbers:
  #   numbers.each do |number|
  #     # barrier.async do |task|
  #     # sleep(number)
  #       STDOUT.flush
  #       puts number
  #

# Rack app
class MyRackApp
  def call(env)
    [
      200,
      {"Content-Type" => "text/plain"},
      ["#{Time.now}"]
    ]
  end
end
