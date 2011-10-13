module RCelery
  class AsyncResult
    def initialize(task_id)
      @task_id = task_id
      @queue = Task.result_queue(task_id)
    end

    def wait
      result_value = :no_result
      @queue.subscribe do |payload|
        result_value = JSON.parse(payload)['result']
      end

      while(result_value == :no_result)
        sleep(0.05)
      end

      @queue.unsubscribe
      result_value
    end
  end
end

