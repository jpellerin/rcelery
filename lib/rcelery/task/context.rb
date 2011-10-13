module RCelery
  class Task
    class Context
      def initialize(name)
        @key = "#{name}.request"
      end

      def update(options = {})
        Thread.current[@key] = options
      end

      def clear
        update
      end

      def method_missing(method, *args)
        if args.length.zero?
          Thread.current[@key][method]
        else
          super(method, *args)
        end
      end
    end
  end
end
