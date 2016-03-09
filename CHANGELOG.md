### Unreleased

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
