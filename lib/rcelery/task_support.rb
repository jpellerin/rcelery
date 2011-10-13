module RCelery
  module TaskSupport
    def self.included(base)
      base.extend(ClassMethods)
    end

    def self.task_name(mod, method)
      parts = mod.split('::') << method.to_s
      klass_name = parts.map do |part|
        part.gsub(/([^\a])([A-Z])/) { "#{$1}_#{$2}" }.downcase
      end.join('.')
    end

    module ClassMethods
      attr_accessor :current_options

      def method_added(method)
        return if @current_options.nil?

        mod = self
        klass = Class.new { include mod }
        bound_method = klass.instance_method(method).bind(klass.new)

        task_name = @current_options[:name] ||
          TaskSupport.task_name(mod.name, method)

        task = Task.new(@current_options.merge(
          :name => task_name,
          :method => bound_method
        ))

        # current_options must be nil'ed before we redefine
        # the method as doing so would trigger this method
        # again and cause an infinite loop
        @current_options = nil
        mod.module_eval do
          alias_method :"_#{method}", method

          define_method(method) do |*args|
            if args.length.zero?
              task
            else
              send(:"_#{method}", *args)
            end
          end
        end

        RCelery::Task.all_tasks[task_name] = task
      end

      def task(options = {})
        @current_options = options
      end
    end
  end
end
