require 'thread'
require 'time'

module RCelery
  class Pool

    def initialize(options={})
      @task_queue = Queue.new
      RCelery.start(options) unless RCelery.running?
    end

    def start
      subscribe
    end

    def subscribe
      # amqp-client has a nice fat TODO in the delivery handler to
      # ack if necessary; we'll just manually do it, however, the
      # call to subscribe still needs :ack => true so the server
      # expects our ack
      RCelery.queue.subscribe(:ack => true) do |header, payload|
        begin
          message = JSON.parse(payload)
          RCelery::Events.task_received(message['id'], message['task'], message['args'], message['kwargs'], nil, message['eta'])

          if message['eta'] && Time.parse(message['eta']) > Time.now
            defer({:message => message, :header => header})
          else
            @task_queue.push({:message => message, :header => header})
          end
        rescue JSON::ParserError
          # not a message we care about
          header.ack
        end
      end
    end

    def defer(task)
      time_difference = (Time.parse(task[:message]['eta']) - Time.now).to_i
      EM.add_timer(time_difference) do
        @task_queue.push(task)
      end
    end

    def poll
      @task_queue.pop
    end

    def unsubscribe
      RCelery.queue.unsubscribe
    end

    def stop
      unsubscribe
      RCelery.stop
    end

  end
end
