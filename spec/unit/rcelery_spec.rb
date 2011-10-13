require 'spec_helper'

describe RCelery do
  before :each do
    stub(AMQP).start
    stub(AMQP).stop

    @options = { :host => 'host', :port => 1234, :application => 'some_app' }
    @channel, @queue = stub_amqp
  end

  after :each do
    RCelery.stop if RCelery.running?
  end

  describe '.start' do
    it 'starts amqp with the connection string based on the options passed less the application option' do
      stub(RCelery).channel { @channel }
      mock(AMQP).start(hash_including({
        :host => 'host',
        :port => 1234,
        :username => 'guest',
        :password => 'guest',
        :vhost => '/'
      }))

      RCelery.start(@options)
    end

    it "doesn't start AMQP if the connection is connected" do
      stub(RCelery).channel { @channel }
      connection = stub!.connected? { true }.subject
      stub(AMQP).connection { connection }

      RCelery.thread.should be_nil
    end

    it 'sets up the request, results and event exchanges' do
      channel = mock!.direct('celery', :durable => true) { 'request exchange' }.subject
      mock(channel).direct('celeryresults', :durable => true, :auto_delete => true) { 'results exchange' }
      mock(channel).topic('celeryev', :durable => true) { 'events exchange' }
      stub(channel).queue { @queue }

      stub(RCelery).channel { channel }

      RCelery.start(@options)

      RCelery.exchanges[:request].should == 'request exchange'
      RCelery.exchanges[:result].should == 'results exchange'
      RCelery.exchanges[:event].should == 'events exchange'
    end

    it 'sets up the request queue and binds it to the request exchange correctly' do
      stub(@channel).direct('celery', anything) { 'request exchange' }
      mock(@channel).queue('rcelery.some_app', :durable => true) { @queue }
      mock(@queue).bind('request exchange', :routing_key => 'rcelery.some_app') { @queue }
      stub(RCelery).channel { @channel }
      RCelery.start(@options)

      RCelery.queue.should == @queue
    end

    it 'sets the running flag to true after completion' do
      stub(RCelery).channel { @channel }

      RCelery.running?.should be_false
      RCelery.start(@options)
      RCelery.running?.should be_true
    end

    it 'returns the self object (RCelery)' do
      stub(RCelery).channel { @channel }
      RCelery.start(@options).should == RCelery
    end

    it "doesn't start anything if eager_mode is set" do
      RCelery.start(@options.merge(:eager_mode => true))
      RCelery.running?.should be_true
    end
  end

  describe '.stop' do
    before :each do
      stub(RCelery).channel { @channel }
      RCelery.start(@options)
    end

    it 'stops AMQP' do
      mock(AMQP).stop

      RCelery.stop
    end

    describe 'updates various pieces of internal state:' do
      before :each do
        RCelery.stop
      end

      it 'sets the running state to false' do
        RCelery.running?.should be_false
      end

      it 'clears the exchanges' do
        RCelery.exchanges.should be_nil
      end

      it 'clears the thread' do
        RCelery.thread.should be_nil
      end

      it 'clears the request queue' do
        RCelery.queue.should be_nil
      end
    end
  end

  describe '.publish' do
    it 'publishes a message to the exchange specified, calling to_json first' do
      exchange = mock!.publish('some message'.to_json, anything).subject
      stub(@channel).direct('celery', anything) { exchange }
      stub(RCelery).channel { @channel }
      RCelery.start(@options)

      RCelery.publish(:request, 'some message', {:some => 'option'})
    end

    it 'uses the application name as the routing key if none is given' do
      exchange = mock!.publish(anything, hash_including({:routing_key => 'rcelery.some_app'})).subject
      stub(@channel).direct('celery', anything) { exchange }
      stub(RCelery).channel { @channel }
      RCelery.start(@options)

      RCelery.publish(:request, 'some message', {:some => 'option'})
    end

    it 'publishes the message with the application/json content_type' do
      exchange = mock!.publish(anything, hash_including({:content_type => 'application/json'})).subject
      stub(@channel).direct('celery', anything) { exchange }
      stub(RCelery).channel { @channel }
      RCelery.start(@options)

      RCelery.publish(:request, 'some message', {:some => 'option'})
    end

    it 'passes any options to the exchange' do
      exchange = mock!.publish(anything, hash_including({:some => 'option'})).subject
      stub(@channel).direct('celery', anything) { exchange }
      stub(RCelery).channel { @channel }
      RCelery.start(@options)

      RCelery.publish(:request, 'some message', {:some => 'option'})
    end
  end
end
