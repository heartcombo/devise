# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "devise/version"

Gem::Specification.new do |s|
  s.name        = "devise"
  s.version     = Devise::VERSION.dup
  s.platform    = Gem::Platform::RUBY  
  s.summary     = "Flexible authentication solution for Rails with Warden"
  s.email       = "contact@plataformatec.com.br"
  s.homepage    = "http://github.com/plataformatec/devise"
  s.description = "Flexible authentication solution for Rails with Warden"
  s.authors     = ['José Valim', 'Carlos Antônio']

  s.rubyforge_project = "devise"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency("warden", "~> 1.0.3")
  s.add_dependency("orm_adapter", "~> 0.0.5")
  s.add_dependency("bcrypt-ruby", "~> 2.1.2")
end