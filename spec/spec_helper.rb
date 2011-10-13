require 'rubygems'
require 'bundler'

Bundler.setup

require 'rspec'
require 'rcelery'

module AMQPMock
  def stub_amqp
    queue = stub!.bind { queue }.subject
    stub(queue).subscribe { queue }
    stub(queue).unsubscribe { queue }
    channel = stub!.direct.subject
    stub(channel).topic
    stub(channel).queue { queue }

    stub(RCelery).channel{ channel }

    [channel, queue]
  end
end

RSpec.configure do |config|
  config.mock_with :rr

  config.before :all do
    stub(AMQP).start
    stub(AMQP).stop
  end

  config.include AMQPMock
end

