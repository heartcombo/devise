### Unreleased

* breaking changes
  * Drop support to Ruby < 2.7
  * Drop support to Rails < 7.0
  * Remove deprecated `:bypass` option from `sign_in` helper, use `bypass_sign_in` instead. [#5803](https://github.com/heartcombo/devise/pull/5803)
  * Remove deprecated `devise_error_messages!` helper, use `render "devise/shared/error_messages", resource: resource` instead. [#5803](https://github.com/heartcombo/devise/pull/5803)
  * Remove deprecated `scope` second argument from `sign_in(resource, :admin)` controller test helper, use `sign_in(resource, scope: :admin)` instead. [#5803](https://github.com/heartcombo/devise/pull/5803)
  * Remove deprecated `Devise::TestHelpers`, use `Devise::Test::ControllerHelpers` instead. [#5803](https://github.com/heartcombo/devise/pull/5803)
  * Remove `SecretKeyFinder` and use `app.secret_key_base` as the default secret key for `Devise.secret_key` if a custom `Devise.secret_key` is not provided.

    This is potentially a breaking change because Devise previously used the following order to find a secret key:

    ```
    app.credentials.secret_key_base > app.secrets.secret_key_base > application.config.secret_key_base > application.secret_key_base
    ```

    Now, it always uses `application.secret_key_base`. Make sure you're using the same secret key after the upgrade; otherwise, previously generated tokens for `recoverable`, `lockable`, and `confirmable` will be invalid.
    [#5645](https://github.com/heartcombo/devise/pull/5645)
* enhancements
  * Removed deprecations warning output for `Devise::Models::Authenticatable::BLACKLIST_FOR_SERIALIZATION` (@soartec-lab)
  * Add Rails 8 support.
    - Routes are lazy-loaded by default in test and development environments now so Devise loads them before `Devise.mappings` call.
  * Add Ruby 3.4 support.
  * Password length validator is changed from

    ```
    validates_length_of :password, within: password_length, allow_blank: true`
    ```

    to

    ```
    validates_length_of :password, minimum: proc { password_length.min }, maximum: proc { password_length.max }, allow_blank: true
    ```

    so it's possible to override `password_length` at runtime. (@manojmj92)
  * Reenable Mongoid test suite across all Rails 7+ versions, to ensure we continue supporting it. Changes to dirty tracking to support Mongoid 8.0+. [#5568](https://github.com/heartcombo/devise/pull/5568)
* bug fixes
  * Make `Devise` work without `ActionMailer` when `Zeitwerk` autoloader is used.

Please check [4-stable](https://github.com/heartcombo/devise/blob/4-stable/CHANGELOG.md)
for previous changes.
