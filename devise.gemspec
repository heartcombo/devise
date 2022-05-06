# -*- encoding: utf-8 -*-
# frozen_string_literal: true

$:.push File.expand_path("../lib", __FILE__)
require "devise/version"

Gem::Specification.new do |s|
  s.name        = "devise"
  s.version     = Devise::VERSION.dup
  s.platform    = Gem::Platform::RUBY
  s.licenses    = ["MIT"]
  s.summary     = "Flexible authentication solution for Rails with Warden"
  s.email       = "heartcombo@googlegroups.com"
  s.homepage    = "https://github.com/heartcombo/devise"
  s.description = "Flexible authentication solution for Rails with Warden"
  s.authors     = ['José Valim', 'Carlos Antônio']
  s.metadata    = {
    "homepage_uri"      => "https://github.com/heartcombo/devise",
    "documentation_uri" => "https://rubydoc.info/github/heartcombo/devise",
    "changelog_uri"     => "https://github.com/heartcombo/devise/blob/main/CHANGELOG.md",
    "source_code_uri"   => "https://github.com/heartcombo/devise",
    "bug_tracker_uri"   => "https://github.com/heartcombo/devise/issues",
    "wiki_uri"          => "https://github.com/heartcombo/devise/wiki"
  }

  s.files         = Dir["{app,config,lib}/**/*", "CHANGELOG.md", "MIT-LICENSE", "README.md"]
  s.require_paths = ["lib"]
  s.required_ruby_version = '>= 2.1.0'

  s.add_dependency("warden", "~> 1.2.3")
  s.add_dependency("orm_adapter", "~> 0.1")
  s.add_dependency("bcrypt", "~> 3.0")
  s.add_dependency("railties", ">= 4.1.0")
  s.add_dependency("responders")
end
