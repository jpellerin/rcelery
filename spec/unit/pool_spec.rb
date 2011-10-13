require 'spec_helper'

describe RCelery::Pool do
  include RR::Adapters::RRMethods

  before(:each) do
    @channel, @queue = stub_amqp
  end

  after :each do
    RCelery.stop if RCelery.running?
  end

  describe '.new' do
    it 'starts RCelery if it is not running' do
      mock.proxy(RCelery).start({:host => 'option'})
      RCelery::Pool.new({:host => 'option'})
    end

    it 'does not start RCelery if it is running' do
      RCelery.start
      dont_allow(RCelery).start({:some => 'option'})
      RCelery::Pool.new(:some => 'option')
    end
  end

  describe '.start' do
    it 'subscribes to the request queue' do
      mock(@queue).subscribe(:ack => true)
      RCelery::Pool.new.start
    end
  end

  describe '.stop' do
    it 'unsubscribes from the queue' do
      pool = RCelery::Pool.new
      pool.start
      mock(@queue).unsubscribe
      pool.stop
    end
  end

  describe '.subscribe' do
    it 'adds tasks to the task queue' do
      pool = RCelery::Pool.new

      message = {
        :id => "blah",
        :task => "blah task",
        :args => [],
        :kwargs => {}
      }

      stub(@queue).subscribe.yields("hello", message.to_json)
      stub(RCelery::Events).task_received

      pool.start

      expected_message = {
        "id" => "blah",
        "task" => "blah task",
        "args" => [],
        "kwargs" => {}
      }

      pool.poll.should == {:message => expected_message, :header => "hello"}
    end

    it 'sends a task received event with the correct information' do
      pool = RCelery::Pool.new

      message = {
        :id => "blah",
        :task => "this.task",
        :args => [1,2,3],
        :kwargs => {:this => "that"}
      }

      stub(@queue).subscribe.yields("hello", message.to_json)
      mock(RCelery::Events).task_received("blah", "this.task", [1,2,3], {"this" => "that"}, nil, nil)
      pool.start
    end

    it 'defers a task if the eta is in the future' do
      pool = RCelery::Pool.new
      tomorrow = DateTime.now.next

      message = {
        :id => "blah",
        :task => "this.task",
        :args => "hi",
        :kwargs => "kwargs",
        :eta => tomorrow.to_s
      }

      stub(@queue).subscribe.yields("hello", message.to_json)
      stub(RCelery::Events).task_received

      expected_message = {
        "id" => "blah",
        "task" => "this.task",
        "args" => "hi",
        "kwargs" => "kwargs",
        "eta" => tomorrow.to_s
      }

      mock(pool).defer({:message => expected_message, :header => "hello"})
      pool.start
    end

    it 'acks messages that fail parsing' do
      pool = RCelery::Pool.new

      header = mock!
      mock(header).ack
      stub(@queue).subscribe.yields(header, "{blah")

      pool.start
    end

  end


end
