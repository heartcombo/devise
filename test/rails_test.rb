# frozen_string_literal: true

require 'test_helper'

class RailsTest < ActiveSupport::TestCase
  test 'correct initializer position' do
    initializer = Devise::Engine.initializers.detect { |i| i.name == 'devise.omniauth' }
    assert_equal :load_config_initializers, initializer.after
    assert_equal :build_middleware_stack, initializer.before
  end

  test 'ignore devise mailer loading when ActionMailer is not defined with zeitwerk' do
    if Devise.rails6_and_up?
      begin
        swap Devise, parent_mailer: 'NotDefinedParentMailer' do
          Devise::Engine.initializers.detect { |initializer| initializer.name == 'devise.zeitwerk' }.block.call
          assert Rails.autoloaders.main.ignored_glob_patterns.any? { |pattern| pattern.include?("mailer.rb") }
        end
      ensure
        Rails.autoloaders.main.instance_variable_set(:@ignored_glob_patterns, Set.new)
      end
    end
  end

  test 'load devise mailer file when Devise.parent_mailer is defined with zeitwerk' do
    if Devise.rails6_and_up?
      Devise::Engine.initializers.detect { |initializer| initializer.name == 'devise.zeitwerk' }.block.call
      refute Rails.autoloaders.main.ignored_glob_patterns.any? { |pattern| pattern.include?("mailer.rb") }
    end
  end
end
