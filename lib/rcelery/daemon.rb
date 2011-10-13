require 'optparse'
require 'rcelery/pool'

module RCelery
  class Daemon
    def initialize(args)
      @config = RCelery::Configuration.new
      opts = OptionParser.new do |opt|
        opt.on('-n', '--hostname HOSTNAME', 'Hostname of the AMQP broker') do |host|
          @config.host = host
        end

        opt.on('-p', '--port PORT', 'Port of the AMQP broker') do |port|
          @config.port = port
        end

        opt.on('-v', '--vhost VHOST', 'Vhost of the AMQP broker') do |vhost|
          @config.vhost = vhost
        end

        opt.on('-u', '--username USERNAME', 'Username to use during authentication with the AMQP broker') do |username|
          @config.username = username
        end

        opt.on('-w', '--password PASSWORD', 'Password to use during authentication with the AMQP broker') do |password|
          @config.password = password
        end

        opt.on('-a', '--application APPLICATION', 'Name of the application') do |application|
          @config.application = application
        end

        opt.on('-t', '--tasks lib1,lib2,...', Array, 'List of libraries to require that contain task definitions') do |requires|
          requires.each do |lib|
            require lib
          end
        end

        opt.on('-r', '--rails', 'Require \'config/environment\' to provide the Rails environment') do
          require 'config/environment'
          ::Rails.logger.auto_flushing = true
        end

        opt.on('-W', '--workers NUMBER', 'The number of workers to launch (default 1)') do |num|
          @config.worker_count = num
        end

        opt.on_tail('-h', '--help', 'Show this message') do
          puts opts
          exit
        end
      end
      opts.parse!(args)
    end

    def run
      pool = RCelery::Pool.new(@config)
      @config.worker_count.times do
        Thread.new do
          @worker = RCelery::Worker.new
          @worker.start pool
        end
      end

      pool.start
      trap_signals
      RCelery.thread.join
    end

    def trap_signals
      block = proc do
        @worker.stop
        RCelery.stop
        exit
      end
      Signal.trap('INT', &block)
      Signal.trap('TERM', &block)
    end
  end
end
