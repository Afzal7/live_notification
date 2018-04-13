$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "live_notifications/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "live_notifications"
  s.version     = LiveNotifications::VERSION
  s.authors     = ["Afzal7"]
  s.email       = ["md.afzal1234@gmail.com"]
  s.homepage    = "https://w3sockets.com"
  s.summary     = "Summary of LiveNotifications."
  s.description = "LiveNotifications"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.8"

  s.add_development_dependency "sqlite3"
end
