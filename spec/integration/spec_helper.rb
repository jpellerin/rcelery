require 'rubygems'
require 'bundler'

Bundler.setup

require 'rspec'
require 'rcelery'
require 'spec/integration/tasks'
require 'timeout'


module Support
  def self.config
    {
      :application => ENV['RCELERY_APPLICATION'] || 'integration',
      :host =>        ENV['RCELERY_HOST'] || 'localhost',
      :port =>        ENV['RCELERY_PORT'] || 5672,
      :vhost =>       ENV['RCELERY_VHOST'] || '/integration',
      :username =>    ENV['RCELERY_USERNAME'] || 'guest',
      :password =>    ENV['RCELERY_PASSWORD'] || 'guest',
      :worker_count => ENV['RCELERY_WORKERS'] || 2
    }
  end
end

RSpec.configure do |config|
  config.mock_with :rr

  config.before :all do
    RCelery.start(Support.config)
  end

  config.after :each do
    RCelery.queue.purge()
  end

  config.around :each do |example|
    Timeout.timeout(15) do
      example.run
    end
  end
end

