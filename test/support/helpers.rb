require 'active_support/test_case'

class ActiveSupport::TestCase
  VALID_AUTHENTICATION_TOKEN = 'AbCdEfGhIjKlMnOpQrSt'.freeze

  def setup_mailer
    ActionMailer::Base.deliveries = []
  end

  def store_translations(locale, translations, &block)
    begin
      I18n.backend.store_translations(locale, translations)
      yield
    ensure
      I18n.reload!
    end
  end

  def generate_unique_email
    @@email_count ||= 0
    @@email_count += 1
    "test#{@@email_count}@example.com"
  end

  def valid_attributes(attributes={})
    { :username => "usertest",
      :email => generate_unique_email,
      :password => '123456',
      :password_confirmation => '123456' }.update(attributes)
  end

  def new_user(attributes={})
    User.new(valid_attributes(attributes))
  end

  def create_user(attributes={})
    User.create!(valid_attributes(attributes))
  end

  def create_admin(attributes={})
    valid_attributes = valid_attributes(attributes)
    valid_attributes.delete(:username)
    Admin.create!(valid_attributes)
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

  def clear_cached_variables(options)
    if options.key?(:case_insensitive_keys) || options.key?(:strip_whitespace_keys)
      Devise.mappings.each do |_, mapping|
        mapping.to.instance_variable_set(:@devise_param_filter, nil)
      end
    end
  end

  def with_rails_version(constants)
    saved_constants = {}

    constants.each do |constant, val|
      saved_constants[constant] = ::Rails::VERSION.const_get constant
      Kernel::silence_warnings { ::Rails::VERSION.const_set(constant, val) }
    end

    begin
      yield
    ensure
      constants.each do |constant, val|
        Kernel::silence_warnings { ::Rails::VERSION.const_set(constant, saved_constants[constant]) }
      end
    end
  end

  # TODO: Get rid of this in favor of a real model with unconfirmed
  def add_unconfirmed_email_column
    if DEVISE_ORM == :active_record
      ActiveRecord::Base.connection.add_column(:users, :unconfirmed_email, :string)
      User.reset_column_information
    elsif DEVISE_ORM == :mongoid
      User.field(:unconfirmed_email, :type => String)
    end
  end

  # TODO: Get rid of this in favor of a real model with unconfirmed
  def remove_unconfirmed_email_column
    if DEVISE_ORM == :active_record
      ActiveRecord::Base.connection.remove_column(:users, :unconfirmed_email)
      User.reset_column_information
    elsif DEVISE_ORM == :mongoid
      User.fields.delete(:unconfirmed_email)
      User.send(:undefine_attribute_methods)
      User.send(:define_attribute_methods, User.fields.keys)
    end
  end
end
