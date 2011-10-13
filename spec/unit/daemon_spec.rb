require 'spec_helper'

describe RCelery::Daemon do
  include RR::Adapters::RRMethods

  before(:each) do
    # @channel, @queue = stub_amqp
  end

  after :each do
    RCelery.stop if RCelery.running?
  end

  describe '.new' do
    it 'sets a config attr' do
      d = RCelery::Daemon.new([])
      d.instance_variable_get(:@config).should be_an_instance_of(RCelery::Configuration)
    end
  end
end

