require 'rcelery/rails'

module RCelery
  class Railtie < ::Rails::Railtie
    railtie_name :rcelery

    initializer "rcelery.rails" do |app|
      RCelery::Rails.initialize
    end
  end
end
