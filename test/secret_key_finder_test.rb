# frozen_string_literal: true

require 'test_helper'

class Rails52SecretKeyBase
  def secret_key_base
    'secret_key_base'
  end
end

class Rails41Secrets
  def secrets
    OpenStruct.new(secret_key_base: 'secrets')
  end

  def config
    OpenStruct.new(secret_key_base: nil)
  end
end

class Rails41Config
  def secrets
    OpenStruct.new(secret_key_base: nil)
  end

  def config
    OpenStruct.new(secret_key_base: 'config')
  end
end

class Rails40Config
  def config
    OpenStruct.new(secret_key_base: 'config')
  end
end

class SecretKeyFinderTest < ActiveSupport::TestCase
  test "rails 5.2+ uses secret_key_base on application to find or create the key" do
    secret_key_finder = Devise::SecretKeyFinder.new(Rails52SecretKeyBase.new)

    assert_equal 'secret_key_base', secret_key_finder.find
  end

  test "rails 4.1 uses secrets" do
    secret_key_finder = Devise::SecretKeyFinder.new(Rails41Secrets.new)

    assert_equal 'secrets', secret_key_finder.find
  end

  test "rails 4.1 uses config when secrets are empty" do
    secret_key_finder = Devise::SecretKeyFinder.new(Rails41Config.new)

    assert_equal 'config', secret_key_finder.find
  end

  test "rails 4.0 uses config" do
    secret_key_finder = Devise::SecretKeyFinder.new(Rails40Config.new)

    assert_equal 'config', secret_key_finder.find
  end
end
