require 'socket'

module RCelery
  class Events
    def self.hostname
      Socket.gethostname
    end

    def self.timestamp
      Time.now.to_f
    end

    def self.task_received(uuid, name, args, kwargs, retries = 0, eta = nil)
      RCelery.publish(:event, {
        :type => 'task-received',
        :uuid => uuid,
        :name => name,
        :args => args,
        :kwargs => kwargs,
        :retries => retries,
        :eta => eta,
        :hostname => hostname,
        :timestamp => timestamp
      }, :routing_key => 'task.received')
    end

    def self.task_started(uuid, pid)
      RCelery.publish(:event, {
        :type => 'task-started',
        :uuid => uuid,
        :hostname => hostname,
        :timestamp => timestamp,
        :pid => pid
      }, :routing_key => 'task.started')
    end

    def self.task_succeeded(uuid, result, runtime)
      RCelery.publish(:event, {
        :type => 'task-succeeded',
        :uuid => uuid,
        :result => result,
        :hostname => hostname,
        :timestamp => timestamp,
        :runtime => runtime,
      }, :routing_key => 'task.succeeded')
    end

    def self.task_failed(uuid, exception, traceback)
      RCelery.publish(:event, {
        :type => 'task-failed',
        :uuid => uuid,
        :exception => exception,
        :traceback => traceback,
        :hostname => hostname,
        :timestamp => timestamp
      }, :routing_key => 'task.failed')
    end

    def self.task_retried(uuid, exception, traceback)
      RCelery.publish(:event, {
        :type => 'task-retried',
        :uuid => uuid,
        :exception => exception,
        :traceback => traceback,
        :hostname => hostname,
        :timestamp => timestamp
      }, :routing_key => 'task.retried')
    end

    def self.worker_online(sw_ident, sw_ver, sw_sys)
      RCelery.publish(:event, {
        :type => 'worker-online',
        :sw_ident => sw_ident,
        :sw_ver => sw_ver,
        :sw_sys => sw_sys,
        :hostname => hostname,
        :timestamp => timestamp
      }, :routing_key => 'worker.online')
    end

    def self.worker_heartbeat(sw_ident, sw_ver, sw_sys)
      RCelery.publish(:event, {
        :type => 'worker-heartbeat',
        :sw_ident => sw_ident,
        :sw_ver => sw_ver,
        :sw_sys => sw_sys,
        :hostname => hostname,
        :timestamp => timestamp
      }, :routing_key => 'worker.heartbeat')
    end

    def self.worker_offline(sw_ident, sw_ver, sw_sys)
      RCelery.publish(:event, {
        :type => 'worker-offline',
        :sw_ident => sw_ident,
        :sw_ver => sw_ver,
        :sw_sys => sw_sys,
        :hostname => hostname,
        :timestamp => timestamp
      }, :routing_key => 'worker.offline')
    end
  end
end
