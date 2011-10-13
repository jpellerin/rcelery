require 'spec_helper'

describe RCelery::Worker do
  include RR::Adapters::RRMethods

  before(:each) do
    @channel, @queue = stub_amqp
  end

  after :each do
    RCelery.stop
  end

  describe '.start' do
    it 'sends a worker online event' do
      mock(RCelery::Events).worker_online('rcelery',RCelery::VERSION,RUBY_PLATFORM)
      stub(RCelery::Events).worker_offline
      pool = RCelery::Pool.new
      worker = RCelery::Worker.new
      stub(worker).subscribe
      worker.start pool
      worker.stop
    end
  end

  describe '.stop' do

    it 'sends a worker offline event' do
      stub(RCelery::Events).worker_online
      mock(RCelery::Events).worker_offline('rcelery',RCelery::VERSION,RUBY_PLATFORM)

      pool = RCelery::Pool.new
      worker = RCelery::Worker.new
      stub(worker).subscribe
      worker.start pool
      worker.stop
    end

    it 'stops the heartbeat' do
      stub(RCelery::Events).worker_online
      stub(RCelery::Events).worker_offline

      pool = RCelery::Pool.new
      worker = RCelery::Worker.new
      stub(worker).subscribe
      worker.start pool
      worker.instance_variable_set(:@heartbeat_timer, mock!.cancel.subject)
      worker.stop
    end
  end

  def fuzzy_hash(expected)
    proc do |arg|
      parsed = JSON.parse(arg)
      good = true
      parsed.each do |k,v|
        next if v.to_s == expected[k].to_s
        good = false
      end
      good
    end
  end
end
