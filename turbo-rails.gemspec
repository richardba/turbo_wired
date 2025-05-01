require_relative "lib/turbo/version"

Gem::Specification.new do |s|
  s.name     = "turbo-rails"
  s.version  = Turbo::VERSION
  s.authors  = [ "Ricardo Oliveira" ]
  s.email    = "richardtrle@youknowwhere"
  s.summary  = "The speed of a single-page web application without having to write any JavaScript."
  s.homepage = "https://github.com/richardba/hotwiredrails"
  s.license  = "MIT"

  s.required_ruby_version = ">= 3.1"

  s.add_dependency "actionpack", ">= 7.1.0"
  s.add_dependency "railties", ">= 7.1.0"

  s.files = Dir["{app,config,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.metadata["changelog_uri"] = "https://github.com/richardba/hotwiredrails/releases"
end
