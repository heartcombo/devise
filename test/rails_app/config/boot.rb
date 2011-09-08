unless defined?(DEVISE_ORM)
  DEVISE_ORM = (ENV["DEVISE_ORM"] || :active_record).to_sym
end

require 'rubygems'
require 'bundler/setup'

$:.unshift File.expand_path('../../../../lib', __FILE__)