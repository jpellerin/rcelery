module RCelery
  class Task
    module States
      SUCCESS = 'SUCCESS'.freeze
      RETRY   = 'RETRY'.freeze
      FAILURE = 'FAILURE'.freeze
    end

    class Runner
      include States

      attr_reader :task, :result, :status

      def initialize(message)
        @task = Task.all_tasks[message['task']]
        @task_id = message['id']
        @eager = message['eager'].nil? ? false : message['eager']

        @args = [message['args'], message['kwargs']].flatten.compact
        @args.pop if @args.last.is_a?(Hash) && @args.last.empty?

        @queue = Task.result_queue(@task_id) unless eager_mode?
        @task.request.update(
          :task_id => @task_id,
          :retries => message['retries'] || 0,
          :args => message['args'],
          :kwargs => message['kwargs']
        )
      end

      def execute
        result = @task.method.call(*@args)
        @status = SUCCESS
        @result = result
        publish_result if publish_result?
      rescue RetryError => raised
        @result = raised
        @status = RETRY
      rescue Exception => raised
        @result = raised
        @status = FAILURE
        publish_result if publish_result?
      ensure
        @task.request.clear
      end

      private
      def publish_result
        traceback = []

        if @status == FAILURE
          traceback = result.backtrace
        end

        RCelery.publish(:result, {
            :result => @result,
            :status => @status,
            :task_id => @task_id,
            :traceback => traceback },
          :routing_key => @task_id.gsub('-', ''),
          :persistent => true)
      end

      def eager_mode?
        @eager == true
      end

      def publish_result?
        @task.ignore_result? == false && eager_mode? == false
      end
    end
  end
end
