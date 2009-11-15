# Use this hook to configure devise mailer, warden hooks and so forth. The first
# four configuration values can also be set straight in your models.
Devise.setup do |config|
  # Invoke `rake secret` and use the printed value to setup a pepper to generate
  # the encrypted password. By default no pepper is used.
  # config.pepper = "rake secret output"

  # Configure how many times you want the password is reencrypted. Default is 10.
  # config.stretches = 10

  # Define which will be the encryption algorithm. Supported algorithms are :sha1
  # (default) and :sha512. Devise also supports encryptors from others authentication
  # frameworks as :clearance_sha1, :authlogic_sha512 (then you should set stretches
  # above to 20 for default behavior) and :restful_authentication_sha1 (then you
  # should set stretches to 10, and copy REST_AUTH_SITE_KEY to pepper)
  # config.encryptor = :sha1

  # Configure which keys are used when authenticating an user. By default is
  # just :email. You can configure it to use [:username, :subdomain], so for
  # authenticating an user, both parameters are required. Remember that those
  # parameters are used only when authenticating and not when retrieving from
  # session. If you need permissions, you should implement that in a before filter.
  # config.authentication_keys = [ :email ]

  # The time you want give to your user to confirm his account. During this time
  # he will be able to access your application without confirming. Default is nil.
  # config.confirm_within = 2.days

  # The time the user will be remembered without asking for credentials again.
  # config.remember_for = 2.weeks

  # Configure the e-mail address which will be shown in DeviseMailer.
  # config.mailer_sender = "foo.bar@yourapp.com"

  # Configure the ORM. Supports :active_record and :mongo_mapper
  # config.orm = :active_record

  # If you want to use other strategies, that are not (yet) supported by Devise,
  # you can configure them inside the config.warden block. The example below
  # allows you to setup OAuth, using http://github.com/roman/warden_oauth
  #
  # config.warden do |manager|
  #   manager.oauth(:twitter) do |twitter|
  #     twitter.consumer_secret = <YOUR CONSUMER SECRET>
  #     twitter.consumer_key  = <YOUR CONSUMER KEY>
  #     twitter.options :site => 'http://twitter.com'
  #   end
  #   manager.default_strategies.unshift :twitter_oauth
  # end

  # Configure default_url_options if you are using dynamic segments in :path_prefix
  # for devise_for.
  #
  # config.default_url_options do
  #   { :locale => I18n.locale }
  # end
end
