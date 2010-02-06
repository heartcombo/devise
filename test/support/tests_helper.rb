class ActiveSupport::TestCase
  VALID_AUTHENTICATION_TOKEN = 'AbCdEfGhIjKlMnOpQrSt'.freeze

  def setup_mailer
    ActionMailer::Base.deliveries = []
  end

  def store_translations(locale, translations, &block)
    begin
      I18n.backend.store_translations locale, translations
      yield
    ensure
      I18n.reload!
    end
  end

  # Helpers for creating new users
  #
  def generate_unique_email
    @@email_count ||= 0
    @@email_count += 1
    "test#{@@email_count}@email.com"
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
end