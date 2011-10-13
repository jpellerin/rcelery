require 'integration/spec_helper'
require 'system_timer'

describe 'Ruby Worker' do
  include Tasks

  it 'is able to consume messages posted by the ruby client' do
    result = subtract.delay(16,9)
    result.wait.should == 7
  end

  it 'is able to consume messages posted by the python client' do
    result = `./spec/integration/python_components/bin/python ./spec/integration/python_components/celery_client.py`.to_i
    result.should == 20
  end

  it 'is able to consume messages with an eta from the python client' do
    result = `./spec/integration/python_components/bin/python ./spec/integration/python_components/celery_deferred_client.py`.to_i
    result.should == 25
  end

  it 'will defer tasks scheduled for the future' do
    sleep_result = sleeper.apply_async(:args => 5, :eta => Time.now + 5)

    SystemTimer.timeout(4) do
      result = subtract.delay(20, 1)
      result.wait.should == 19
    end

    sleep_result.wait.should == 'FINISH'
  end

  it 'will retry a failed task' do
    task_id = UUID.generate
    stub(UUID).generate { task_id }

    channel = RCelery.channel
    event_queue = channel.queue('retries', :durable => true).bind(
      RCelery.exchanges[:event], :routing_key => 'task.retried')

    retries = 0
    event_queue.subscribe do |header, payload|
      event = JSON.parse(payload)
      retries += 1 if event['uuid'] == task_id
    end

    result = retrier.delay(2)

    result.wait.should == 'FINISH'
    retries.should == 2

    event_queue.unsubscribe
  end

  it 'will not exceed the max retries (default 3)' do
    task_id = UUID.generate
    stub(UUID).generate { task_id }

    channel = RCelery.channel
    event_queue = channel.queue('failed_retries', :durable => true).bind(
      RCelery.exchanges[:event], :routing_key => 'task.retried')

    retries = 0
    event_queue.subscribe do |header, payload|
      event = JSON.parse(payload)
      retries += 1 if event['uuid'] == task_id
    end

    result = retrier.delay(4)

    result.wait.should =~ /MaxRetriesExceeded/
    retries.should == 3

    event_queue.unsubscribe
  end

  it 'is able to concurrently process tasks' do
    sleep_result = sleeper.delay(5)
    sleep(1)

    SystemTimer.timeout(3) do
      subtract_result = subtract.delay(20,1)
      subtract_result.wait.should == 19
    end

    sleep_result.wait.should == "FINISH"
  end

  it 'is able to concurrently process many of the same task' do
    add_result1 = add.delay(5,5)
    add_result2 = add.delay(6,7)
    add_result3 = add.delay(7,9)

    add_result1.wait.should == 10
    add_result2.wait.should == 13
    add_result3.wait.should == 16
  end

  it 'is able to concurrently retry many of the same task' do
    result1 = noop_retry.delay(1)
    result2 = noop_retry.delay(2)
    result3 = noop_retry.delay(3)
    result4 = noop_retry.delay(4)
    result5 = noop_retry.delay(5)
    result6 = noop_retry.delay(6)

    result1.wait.should == 1
    result2.wait.should == 2
    result3.wait.should == 3
    result4.wait.should == 4
    result5.wait.should == 5
    result6.wait.should == 6
  end
end

