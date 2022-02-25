# frozen_string_literal: true

ENV["RAILS_ENV"] = "test"
DEVISE_ORM = (ENV["DEVISE_ORM"] || :active_record).to_sym

$:.unshift File.dirname(__FILE__)
puts "\n==> Devise.orm = #{DEVISE_ORM.inspect}"

require "rails_app/config/environment"
require "rails/test_help"
require "orm/#{DEVISE_ORM}"

I18n.load_path << File.expand_path("../support/locale/en.yml", __FILE__)

require 'mocha/minitest'
require 'timecop'
require 'webrat'

# Monkey patch for Nokogiri changes - https://github.com/sparklemotion/nokogiri/issues/2469
module Webrat
  module Matchers
    class HaveSelector
      def query
          Nokogiri::CSS.parse(@expected.to_s).map do |ast|
            ast.to_xpath("//", Nokogiri::CSS::XPathVisitor.new)
          end.first
      end
    end
  end
end

Webrat.configure do |config|
  config.mode = :rails
  config.open_error_files = false
end

if ActiveSupport.respond_to?(:test_order)
  ActiveSupport.test_order = :random
end

OmniAuth.config.logger = Logger.new('/dev/null')

# Add support to load paths so we can overwrite broken webrat setup
$:.unshift File.expand_path('../support', __FILE__)
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# For generators
require "rails/generators/test_case"
require "generators/devise/install_generator"
require "generators/devise/views_generator"
require "generators/devise/controllers_generator"
