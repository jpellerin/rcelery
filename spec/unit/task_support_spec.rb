require 'spec_helper'

describe RCelery::TaskSupport do
  describe '.included' do
    it 'extends the subject with TaskSupport::ClassMethods' do
      mod = Module.new { include RCelery::TaskSupport }
      mod.should respond_to(:task)
      mod.should respond_to(:method_added)
    end
  end

  describe '.task_name' do
    it 'returns a dotted lowercase task name' do
      task_name = RCelery::TaskSupport.task_name('Some::InnerMod', :Method)
      task_name.should == 'some.inner_mod.method'
    end
  end

  describe RCelery::TaskSupport::ClassMethods do
    before :each do
      @mod = Module.new { include RCelery::TaskSupport }
    end

    describe '#task' do
      it 'sets the current task options for the method defined next' do
        @mod.task(:some_option => true)
        @mod.current_options.should == {:some_option => true}
      end
    end

    describe '#method_added' do
      after :each do
        RCelery::Task.all_tasks.delete('some_method')
        RCelery::Task.all_tasks.delete('another_method')
      end

      describe 'when the current_options are set' do
        describe 'it replaces the new method with another one that'
        it 'returns a RCelery::Task object when it is called with no arguments' do
          mod = @mod
          mod.task(:some_option => true)
          mod.send(:define_method,:some_method) do
            "not returned"
          end

          klass = Class.new { include mod }
          klass.new.some_method.should be_a(RCelery::Task)
        end

        it 'returns normally when called with arguments and is executed with the expected binding' do
          mod = @mod
          mod.task(:some_option => true)
          mod.send(:define_method,:some_method) do |a|
            a + @b
          end

          klass = Class.new do
            include mod

            def initialize(b)
              @b = b
            end
          end
          klass.new(2).some_method(1).should == 3
        end

        it 'takes an argument nil for methods that have an arity of 0 and returns normally' do
          mod = @mod
          mod.task(:some_option => true)
          mod.send(:define_method,:some_method) do
            "returned"
          end

          klass = Class.new { include mod }
          klass.new.some_method(nil).should == 'returned'
        end

        it 'creates an RCelery::Task that has a method with the correct binding' do
          mod = @mod
          mod.task(:some_option => true)
          mod.send(:define_method,:some_method) do
            another_method
          end
          mod.send(:define_method,:another_method) do
            'returned'
          end

          klass = Class.new { include mod }
          klass.new.some_method.method.call.should == 'returned'
        end
      end
    end
  end
end
