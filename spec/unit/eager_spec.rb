require 'spec_helper'

describe RCelery::Task do
  module Tasks
    include RCelery::TaskSupport

    task(:name => 'different_name', :ignore_result => false)
    def add(a,b, options = {})
      noop(a + b + (options['c'] || 0))
    end

    task()
    def ignore
      'ignore_me'
    end

    def noop(val)
      val
    end
  end

  before :each do
    @task = RCelery::Task.all_tasks['different_name']
  end

  after :each do
    RCelery.stop
  end

  describe '#apply_async' do
    it 'works with just args' do
      RCelery.start(:eager_mode => true)
      @task.apply_async(:args => [1,2]).wait.should == 3
    end

    it 'works with args and kwargs' do
      RCelery.start(:eager_mode => true)
      @task.apply_async(:args => [1,2], :kwargs => {'c' => 1}).wait.should == 4
    end

    it 'json encodes and decodes the args to mimic the over the wire process' do
      RCelery.start(:eager_mode => true)
      @task.apply_async(:args => [1,2], :kwargs => {:c => 1}).wait.should == 4
    end
  end
end
