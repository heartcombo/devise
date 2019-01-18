# frozen_string_literal: true

require 'test_helper'

class Rails52Credentials
  def credentials
    OpenStruct.new(secret_key_base: 'credentials')
  end
end

class Rails52Secrets
  def credentials
    OpenStruct.new(secret_key_base: nil)
  end

  def secrets
    OpenStruct.new(secret_key_base: 'secrets')
  end
end

class Rails52Config
  def credentials
    OpenStruct.new(secret_key_base: nil)
  end

  def secrets
    OpenStruct.new(secret_key_base: nil)
  end

  def config
    OpenStruct.new(secret_key_base: 'config')
  end
end

class Rails52SecretKeyBase
  def credentials
    OpenStruct.new(secret_key_base: nil)
  end

  def secrets
    OpenStruct.new(secret_key_base: nil)
  end

  def config
    OpenStruct.new(secret_key_base: nil)
  end

  def secret_key_base
    'secret_key_base'
  end
end

class SecretKeyFinderTest < ActiveSupport::TestCase
  test "rails 5.2 uses credentials when they're available" do
    secret_key_finder = Devise::SecretKeyFinder.new(Rails52Credentials.new)

    assert_equal 'credentials', secret_key_finder.find
  end

  test "rails 5.2 uses secrets when credentials are empty" do
    secret_key_finder = Devise::SecretKeyFinder.new(Rails52Secrets.new)

    assert_equal 'secrets', secret_key_finder.find
  end

  test "rails 5.2 uses config when secrets are empty" do
    secret_key_finder = Devise::SecretKeyFinder.new(Rails52Config.new)

    assert_equal 'config', secret_key_finder.find
  end

  test "rails 5.2 uses secret_key_base when config is empty" do
    secret_key_finder = Devise::SecretKeyFinder.new(Rails52SecretKeyBase.new)

    assert_equal 'secret_key_base', secret_key_finder.find
  end
end
