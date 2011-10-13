require 'qusion'

module RCelery
  def self.thread
    @thread ||= Qusion.thread
  end

  module Rails
    def self.initialize
      config_file = File.join(::Rails.root, 'config', 'rcelery.yml')
      raw_config = nil

      if File.exists?(config_file)
        raw_config = YAML.load_file(config_file)[::Rails.env]
      end

      unless raw_config.nil?
        config = RCelery::Configuration.new(raw_config)
        if config.eager_mode
          RCelery.start(config)
        else
          Qusion.start(config.to_hash) do
            RCelery.start(config)
          end
        end
      end
    end
  end
end
