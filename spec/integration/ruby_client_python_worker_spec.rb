require 'integration/spec_helper'
require 'system_timer'

describe 'Ruby Client' do
  include Tasks

  it 'is able to talk to a python worker' do
    result = add.delay(5,10)
    result.wait.should == 15
  end

  it 'can send tasks scheduled in the future to python workers' do
    result = add.apply_async(:args => [5,3], :eta => Time.now + 5)

    result.wait.should == 8
  end
end
