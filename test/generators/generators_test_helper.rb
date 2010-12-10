require "rubygems"
require "rails/generators/test_case"
require File.expand_path("../../../lib/generators/devise/install_generator", __FILE__)
require File.expand_path("../../../lib/generators/devise/views_generator", __FILE__)
require File.expand_path("../../../lib/generators/#{DEVISE_ORM}/devise_generator", __FILE__)