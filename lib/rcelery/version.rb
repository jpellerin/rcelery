module RCelery
  unless const_defined?(:VERSION)
    spec = Gem::Specification.load(File.dirname(__FILE__) + '/../../rcelery.gemspec')
    VERSION = spec.version
  end
end
