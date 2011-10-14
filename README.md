rCelery: celery for Ruby
========================

rCelery is a Ruby port of [celery] (http://github/ask/celery), the distributed task queue for python. It does not support all of the features of celery, but does interoperate well with it, as long as both sides use the AMQP backend and json serializer.

Example
-------

tasks.rb:

    require 'rcelery'

    module Tasks
      include RCelery::TaskSupport

      class EvenNumberError < StandardError; end

      task(:ignore_result => false)
      def add(a,b, options = {})
        sum = a+b
        if (sum % 2).zero?
          raise EvenNumberError
        else
          return sum
        end
      rescue EvenNumberError => raised
        add.retry(:args => [a+(options['inc_by'] || 1), b], :eta => Time.now, :exc => raised)
      end

      task(:ignore_result => false, :name => 'some.different.name')
      def subtract(a,b)
        a-b
      end
    end

daemon.rb:

    $: << File.dirname(__FILE__)
    require 'rubygems'
    require 'bundler'
    Bundler.require

    require 'rcelery'
    require 'tasks'

    RCelery::Worker.start

client.rb:

    $: << File.dirname(__FILE__)
    require 'rubygems'
    require 'bundler'
    Bundler.require

    require 'rcelery'
    require 'tasks'

    RCelery.start

    include Tasks

    sum = add.delay(1,2)
    difference = subtract.delay(1,2)

    puts "Local Add Result: #{add(1,2)}"
    puts "Local Subtract Result: #{subtract(1,2)}"

    puts "Retrieved Add Result: #{sum.wait}"
    puts "Retrieved Subtract Result: #{difference.wait}"

    retried_sum = add.delay(2,2)
    puts "Successful Retried Add Result: #{retried_sum.wait}"

    retried_sum = add.delay(2,2, :inc_by => 2)
    puts "Failed Retried Add Result: #{retried_sum.wait}"

