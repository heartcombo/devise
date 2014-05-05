$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "rails_engine/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "rails_engine"
  s.version     = RailsEngine::VERSION
  s.summary     = "Engine route testing."
  s.authors     = "David Henry"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile"]

  s.add_dependency "rails"
  s.add_dependency "devise"
end
