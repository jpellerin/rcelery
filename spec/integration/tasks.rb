module Tasks
  include RCelery::TaskSupport

  task(:name => 'r_celery.integration.subtract', :ignore_result => false)
  def subtract(a,b)
    a - b
  end

  task(:name => 'r_celery.integration.multiply', :ignore_result => false)
  def multiply(a,b)
    a * b
  end

  task(:name => 'r_celery.integration.add', :ignore_result => false)
  def add(a,b)
    a + b
  end

  task(:name => 'r_celery.integration.sleep', :ignore_result => false)
  def sleeper(t)
    sleep(t.to_i)
    'FINISH'
  end

  task(:name => 'r_celery.integration.retry', :ignore_result => false)
  def retrier(retries = 0)
    retrier.retry(:args => [retries-1], :eta => Time.now)  unless retries.zero?
    'FINISH'
  end

  task(:name => 'r_celery.integration.noop_retry', :ignore_result => false)
  def noop_retry(a)
    noop_retry.retry(:eta => Time.now)
  rescue RCelery::Task::MaxRetriesExceededError
    a
  end
end
