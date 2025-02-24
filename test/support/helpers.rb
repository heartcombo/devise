# frozen_string_literal: true

require 'active_support/test_case'

class ActiveSupport::TestCase
  def setup_mailer
    ActionMailer::Base.deliveries = []
  end

  def store_translations(translations)
    # Eager-loading the backend before storing the translations ensures that the I18n backend will
    # always be initialized before we store our custom translations, so the test-specific
    # translations override the translations from the YML files. Locking on a mutex guarantees that
    # concurrent tests calling the same method don't interfere with each other. Note that I18n has a
    # global state so all interactions with it outside of store_translations may cause unexpected
    # runtime errors.
    self.class.i18n_mutex.lock
    I18n.backend.eager_load!
    original_locales = I18n.available_locales
    I18n.available_locales = Set.new(original_locales + translations.keys).to_a
    translations.each { |locale, entries| I18n.backend.store_translations(locale, entries) }
    yield
  ensure
    I18n.available_locales = original_locales
    I18n.reload!
    self.class.i18n_mutex.unlock
  end

  def generate_unique_email
    @@email_count ||= 0
    @@email_count += 1
    "test#{@@email_count}@example.com"
  end

  def valid_attributes(attributes = {})
    { username: "usertest",
      email: generate_unique_email,
      password: '12345678',
      password_confirmation: '12345678' }.update(attributes)
  end

  def new_user(attributes = {})
    User.new(valid_attributes(attributes))
  end

  def create_user(attributes = {})
    User.create!(valid_attributes(attributes))
  end

  def create_admin(attributes = {})
    valid_attributes = valid_attributes(attributes)
    valid_attributes.delete(:username)
    Admin.create!(valid_attributes)
  end

  def create_user_without_email(attributes = {})
    UserWithoutEmail.create!(valid_attributes(attributes))
  end

  def create_user_with_validations(attributes = {})
    UserWithValidations.create!(valid_attributes(attributes))
  end

  # Execute the block setting the given values and restoring old values after
  # the block is executed.
  def swap(object, new_values)
    old_values = {}
    new_values.each do |key, value|
      old_values[key] = object.send key
      object.send :"#{key}=", value
    end
    clear_cached_variables(new_values)
    yield
  ensure
    clear_cached_variables(new_values)
    old_values.each do |key, value|
      object.send :"#{key}=", value
    end
  end

  def swap_model_config(model, new_values)
    new_values.each do |key, value|
      model.send :"#{key}=", value
    end
    yield
  ensure
    new_values.each_key do |key|
      model.remove_instance_variable :"@#{key}"
    end
  end

  def clear_cached_variables(options)
    if options.key?(:case_insensitive_keys) || options.key?(:strip_whitespace_keys)
      Devise.mappings.each do |_, mapping|
        mapping.to.instance_variable_set(:@devise_parameter_filter, nil)
      end
    end
  end

  def self.i18n_mutex
    @i18n_mutex ||= Mutex.new
  end
end
