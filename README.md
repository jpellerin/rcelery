RCelery: celery for Ruby
========================

RCelery is a Ruby port of [celery] (http://github/ask/celery), the distributed task queue for python. It does not support all of the features of celery, but does interoperate well with it, as long as both sides use the AMQP backend and json serializer.

Example
-------

*Note:* To run the example as-is, rabbitmq must be running and accepting connections on localhost port 5672. Access must be allowed to the default vhost for the default username and password.

tasks.rb:

```ruby
require 'rcelery'

module Tasks
  include RCelery::TaskSupport

  task(:ignore_result => false)
  def subtract(a,b)
    a-b
  end
end
```

client.rb:

```ruby
require 'rubygems'
require 'rcelery'
require 'tasks'

RCelery.start

include Tasks

difference = subtract.delay(1,2)
puts "Subtract Result: #{difference.wait}"
```

Run the example:

```shell
$ ruby bin/rceleryd -t tasks.rb &
$ ruby client.rb
```

See the [RCelery docmentation](http://leapfrogdevelopment.github.com/rcelery/) for more information.
