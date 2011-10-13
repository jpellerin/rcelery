require 'uuid'
require 'json'
require 'rcelery/task/runner'
require 'rcelery/task/context'

module RCelery
  class Task
    class RetryError < StandardError; end
    class MaxRetriesExceededError < StandardError; end

    class << self
      attr_accessor :result_queue_expires, :max_retries
    end

    self.max_retries = 3
    self.result_queue_expires = 3600000

    attr_reader :name, :method, :request

    def self.all_tasks
      @all_tasks ||= {}
    end

    def self.execute(message)
      runner = Runner.new(message)
      runner.execute
      runner
    end

    def self.result_queue(task_id)
      queue_name = task_id.gsub('-', '')
      RCelery.channel.queue(
        queue_name,
        :durable => true,
        :auto_delete => true,
        :arguments => {'x-expires' => result_queue_expires}
      ).bind(
        RCelery.exchanges[:result],
        :routing_key => queue_name
      )
    end

    def initialize(options = {})
      @name = options[:name]
      @method = options[:method]
      @routing_key = options[:routing_key]
      @ignore_result = options[:ignore_result].nil? ?
        true : options[:ignore_result]
      @request = Context.new(@name)
    end

    def delay(*args)
      kwargs = args.pop if args.last.is_a?(Hash)
      apply_async(:args => args, :kwargs => kwargs)
    end

    def retry(options = {})
      args = options[:args] || request.args
      kwargs = options[:kwargs] || request.kwargs
      max_retries = options[:max_retries] || self.class.max_retries

      if (request.retries + 1) > max_retries
        if options[:exc]
          raise options[:exc]
        else
          raise MaxRetriesExceededError
        end
      end

      apply_async(
        :args => args,
        :kwargs => kwargs,
        :task_id => request.task_id,
        :retries => request.retries + 1,
        :eta => options[:eta] || default_eta
      )

      raise RetryError
    end

    def apply_async(options = {})
      task_id = options[:task_id] || UUID.generate
      task = {
        :id => task_id,
        :task => @name,
        :args => options[:args],
        :kwargs => options[:kwargs] || {}
      }
      task[:eta] = options[:eta].strftime("%Y-%m-%dT%H:%M:%S") if options[:eta]
      task[:retries] = options[:retries] if options[:retries]

      if RCelery.eager_mode?
        task[:eager] = true
        runner = Task.execute(JSON.parse(task.to_json))
        return (EagerResult.new(runner.result) unless ignore_result?)
      end

      pub_opts = {
        :persistent => true,
        :routing_key => options[:routing_key] || @routing_key
      }

      # initialize result queue first to avoid races
      res = ignore_result? ? nil: AsyncResult.new(task_id)
      RCelery.publish(:request, task, pub_opts)
      res
    end

    def ignore_result?
      @ignore_result
    end

    private
      def default_eta
        Time.at(Time.now + (60 * 3))
      end
  end
end
