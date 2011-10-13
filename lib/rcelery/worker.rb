require 'singleton'
require 'forwardable'
require 'json'
require 'benchmark'

module RCelery
  class Worker
    include Task::States

    class << self
      extend Forwardable
      def_delegators :start, :stop, :join
    end

    def initialize
      @heartbeat = 60
      @poll_interval = 0.5

      @ident = 'rcelery'
      @version  = RCelery::VERSION
      @system = RUBY_PLATFORM
    end

    def start(pool)
      RCelery::Events.worker_online(@ident, @version, @system)
      @pool = pool
      start_heartbeat
      subscribe
    end

    def subscribe
      loop do
        consume @pool.poll
      end
    end

    def stop
      stop_heartbeat
      RCelery::Events.worker_offline(@ident, @version, @system)
    end

  private
    def start_heartbeat
      @heartbeat_timer = EM.add_periodic_timer(@heartbeat) do
        RCelery::Events.worker_heartbeat(@ident, @version, @system)
      end
    end

    def stop_heartbeat
      @heartbeat_timer.cancel unless @heartbeat_timer.nil?
    end

    def consume(data)
      message = data[:message]
      header = data[:header]

      RCelery::Events.task_started(message['id'], Process.pid)

      runner = nil
      runtime = Benchmark.realtime do
        runner = Task.execute(message)
      end

      case runner.status
        when SUCCESS
          RCelery::Events.task_succeeded(message['id'], runner.result, runtime)
        when RETRY
          RCelery::Events.task_retried(message['id'], runner.result, runner.result.backtrace)
        when FAILURE
          RCelery::Events.task_failed(message['id'], runner.result, runner.result.backtrace)
      end

      header.ack
    end
  end
end
