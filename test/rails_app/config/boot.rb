begin
  require File.expand_path("../../../../.bundle/environment", __FILE__)
rescue LoadError
  require 'rubygems'
  require 'bundler'
  Bundler.setup :default, DEVISE_ORM
end

$:.unshift File.expand_path('../../../../lib', __FILE__)