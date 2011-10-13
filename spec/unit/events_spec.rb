require 'spec_helper'

describe RCelery::Events do
  include RR::Adapters::RRMethods

  describe "helper methods" do

    describe ".hostname" do
      it "returns the hostname" do
        RCelery::Events.hostname.should == Socket.gethostname
      end
    end

    describe ".timestamp" do
      it "returns the time" do
        stub(Time).now.returns(6)
        RCelery::Events.timestamp.should == 6.0
      end
    end

  end

  describe "event methods" do

    before(:each) do
      stub(RCelery::Events).timestamp.returns('the time')
      stub(RCelery::Events).hostname.returns('hostname')
    end

    describe '.task_received' do
      it "publishes a task.received event" do
        mock(RCelery).publish(:event, {
          :type => 'task-received',
          :uuid => 'uuid',
          :name => 'name',
          :args => 'args',
          :kwargs => 'kwargs',
          :retries => 'retries',
          :eta => 'eta',
          :hostname => 'hostname',
          :timestamp => 'the time',
        }, :routing_key => 'task.received')
        RCelery::Events.task_received('uuid', 'name', 'args', 'kwargs', 'retries', 'eta')
      end
    end

    describe '.task_started' do
      it "publishes a task.started event" do
        mock(RCelery).publish(:event, {
          :type => 'task-started',
          :uuid => 'uuid',
          :hostname => 'hostname',
          :timestamp => 'the time',
          :pid => 'pid',
        }, :routing_key => 'task.started')
        RCelery::Events.task_started('uuid', 'pid')
      end
    end

    describe '.task_succeeded' do
      it "publishes a task.succeeded event" do
        mock(RCelery).publish(:event, {
          :type => 'task-succeeded',
          :uuid => 'uuid',
          :result => 'result',
          :hostname => 'hostname',
          :timestamp => 'the time',
          :runtime => 'runtime',
        }, :routing_key => 'task.succeeded')
        RCelery::Events.task_succeeded('uuid', 'result', 'runtime')
      end
    end

    describe '.task_failed' do
      it "publishes a task.failed event" do
        mock(RCelery).publish(:event, {
          :type => 'task-failed',
          :uuid => 'uuid',
          :exception => 'exception',
          :traceback => 'traceback',
          :hostname => 'hostname',
          :timestamp => 'the time',
        }, :routing_key => 'task.failed')
        RCelery::Events.task_failed('uuid', 'exception', 'traceback')
      end
    end

    describe '.task_retried' do
      it "publishes a task.retried event" do
        mock(RCelery).publish(:event, {
          :type => 'task-retried',
          :uuid => 'uuid',
          :exception => 'exception',
          :traceback => 'traceback',
          :hostname => 'hostname',
          :timestamp => 'the time',
        }, :routing_key => 'task.retried')
        RCelery::Events.task_retried('uuid', 'exception', 'traceback')
      end
    end

    describe '.worker_online' do
      it "publishes a worker.online event" do
        mock(RCelery).publish(:event, {
          :type => "worker-online",
          :sw_ident => "rcelery",
          :sw_ver => "1.0",
          :sw_sys => RUBY_PLATFORM,
          :hostname => 'hostname',
          :timestamp => 'the time'
        }, :routing_key => "worker.online")

        RCelery::Events.worker_online("rcelery", "1.0", RUBY_PLATFORM)
      end
    end

    describe '.worker_heartbeat' do
      it 'publishes a worker.heartbeat event' do
        mock(RCelery).publish(:event, {
          :type => "worker-heartbeat",
          :sw_ident => "rcelery",
          :sw_ver => "1.0",
          :sw_sys => RUBY_PLATFORM,
          :hostname => 'hostname',
          :timestamp => 'the time'
        }, :routing_key => "worker.heartbeat")

        RCelery::Events.worker_heartbeat("rcelery", "1.0", RUBY_PLATFORM)
      end
    end

    describe '.worker_offline' do
      it 'publishes a worker.offline event' do
        mock(RCelery).publish(:event, {
          :type => "worker-offline",
          :sw_ident => "rcelery",
          :sw_ver => "1.0",
          :sw_sys => RUBY_PLATFORM,
          :hostname => 'hostname',
          :timestamp => 'the time'
        }, :routing_key => "worker.offline")

        RCelery::Events.worker_offline("rcelery", "1.0", RUBY_PLATFORM)
      end
    end

  end
end

