module RCelery
  class EagerResult
    attr_accessor :wait

    def initialize(value)
      @wait = value
    end

  end
end
