### Unreleased

* Remove code supporting old session serialization format (by @fphilipe).

### 4.0.1 - 2016-04-25

* bug fixes
  * Fix the e-mail confirmation instructions send when a user updates the email
    address from nil. (by @lmduc)
  * Remove unnecessary `attribute_will_change!` call. (by @cadejscroggins)
  * Consistent `permit!` check. (by @ulissesalmeida)

### 4.0.0 - 2016-04-18

* bug fixes
  * Fix the `extend_remember_period` configuration. When set to `false` it does
    not update the cookie expiration anymore.(by @ulissesalmeida)

* deprecations
  * Added a warning of default value change in Devise 4.1 for users that uses
    the the default configuration of the following configurations: (by @ulissesalmeida)
    * `strip_whitespace_keys` - The default will be `[:email]`.
    * `skip_session_storage` - The default will be `[:http_auth]`.
    * `sign_out_via` - The default will be `:delete`.
    * `reconfirmable` - The default will be `true`.
    * `email_regexp` - The default will be `/\A[^@\s]+@[^@\s]+\z/`.
  * Removed deprecated argument of `Devise::Models::Rememberable#remember_me!` (by @ulissesalmeida)
  * Removed deprecated private method Devise::Controllers::Helpers#expire_session_data_after_sign_in!
    (by @bogdanvlviv)

### 4.0.0.rc2 - 2016-03-09

* enhancements
  * Introduced `DeviseController#set_flash_message!` for conditional flash
    messages setting to reduce complexity.
  * `rails g devise:install` will fail if the app does not have a ORM configured
    (by @arjunsharma)
  * Support to Rails 5 versioned migrations added.

* deprecations
  * omniauth routes are no longer defined with a wildcard `:provider` parameter,
    and provider specific routes are defined instead, so route helpers like `user_omniauth_authorize_path(:github)` are deprecated in favor of `user_github_authorize_path`.
    You can still use `omniauth_authorize_path(:user, :github)` if you need to
    call the helpers dynamically.

### 4.0.0.rc1 - 2016-01-02

* Support added to Rails 5 (by @twalpole).
* Devise no longer supports Rails 3.2 and 4.0.
* Devise no longer supports Ruby 1.9 and 2.0.

* deprecations
  * The `devise_parameter_sanitize` API has changed:
    The `for` method was deprecated in favor of `permit`:

    ```ruby
    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:sign_up) << :subscribe_newsletter
      # Should become the following.
      devise_parameter_sanitizer.permit(:sign_up, keys: [:subscribe_newsletter])
    end
    ```

    The customization through instance methods on the sanitizer implementation
    should be done through it's `initialize` method:

    ```ruby
    class User::ParameterSanitizer < Devise::ParameterSanitizer
      def sign_up
        default_params.permit(:username, :email)
      end
    end

    # The `sign_up` method can be a `permit` call on the sanitizer `initialize`.

    class User::ParameterSanitizer < Devise::ParameterSanitizer
      def initialize(*)
        super
        permit(:sign_up, keys: [:username, :email])
      end
    end
    ```

    You can check more examples and explanations on the [README section](/plataformatec/devise#strong-parameters)
    and on the [ParameterSanitizer docs](lib/devise/parameter_sanitizer.rb).

Please check [3-stable](https://github.com/plataformatec/devise/blob/3-stable/CHANGELOG.md)
for previous changes.
