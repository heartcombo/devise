begin
  require 'warden'
rescue
  gem 'hassox-warden'
  require 'warden'
end

begin
  require 'rails_warden'
rescue
  gem 'hassox-rails_warden'
  require 'rails_warden'
end

require 'devise/initializers/warden'

module Devise

  # Shortcut method for including all devise modules inside your User class
  # Examples:
  #   # include only authenticable module (default)
  #   acts_as_devisable
  #   # include authenticable + confirmable modules
  #   acts_as_devisable :confirmable
  #   # include authenticable + recoverable modules
  #   acts_as_devisable :recoverable
  #   # include authenticable + validatable modules
  #   acts_as_devisable :validatable
  #   # include all modules
  #   acts_as_devisable :confirmable, :recoverable, :validatable
  #   # shortcut to include all modules (same as above)
  #   acts_as_devisable :all
  #
  def acts_as_devisable(*options)
    include Devise::Models::Authenticable
    include Devise::Models::Confirmable if [:all, :confirmable].any?{|o| options.include?(o) }
    include Devise::Models::Recoverable if [:all, :recoverable].any?{|o| options.include?(o) }
    include Devise::Models::Validatable if [:all, :validatable].any?{|o| options.include?(o) }
  end
end

ActionView::Base.send :include, DeviseHelper
ActionController::Base.send :include, Devise::Controllers::Authenticable
ActiveRecord::Base.send :extend, Devise
