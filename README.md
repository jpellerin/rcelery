rCelery: celery for Ruby
========================

rCelery is a Ruby port of [celery] (http://github/ask/celery), the distributed task queue for python. It does not support all of the features of celery, but does interoperate well with it, as long as both sides use the AMQP backend and json serializer.

Example
-------

tasks.rb:

    require 'rcelery'

    module Tasks
      include RCelery::TaskSupport

      task(:ignore_result => false)
      def subtract(a,b)
        a-b
      end
    end

client.rb:

    $: << File.dirname(__FILE__)
    require 'rubygems'
    require 'bundler'
    Bundler.require

    require 'rcelery'
    require 'tasks'

    RCelery.start

    include Tasks

    difference = subtract.delay(1,2)
    puts "Subtract Result: #{difference.wait}"

Run the example:

    $ bundle exec bin/rceleryd -t tasks.rb &
    $ bundle exec client.rb
