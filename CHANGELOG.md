### Unreleased

* breaking changes
  * Drop support to Ruby < 2.7
  * Drop support to Rails < 7.0
  * Remove deprecated `:bypass` option from `sign_in` helper, use `bypass_sign_in` instead. [#5803](https://github.com/heartcombo/devise/pull/5803)
  * Remove deprecated `devise_error_messages!` helper, use `render "devise/shared/error_messages", resource: resource` instead. [#5803](https://github.com/heartcombo/devise/pull/5803)
  * Remove deprecated `scope` second argument from `sign_in(resource, :admin)` controller test helper, use `sign_in(resource, scope: :admin)` instead. [#5803](https://github.com/heartcombo/devise/pull/5803)
  * Remove deprecated `Devise::TestHelpers`, use `Devise::Test::ControllerHelpers` instead. [#5803](https://github.com/heartcombo/devise/pull/5803)
  * Remove deprecated `Devise::Models::Authenticatable::BLACKLIST_FOR_SERIALIZATION` [#5598](https://github.com/heartcombo/devise/pull/5598)
  * Remove `SecretKeyFinder` and use `app.secret_key_base` as the default secret key for `Devise.secret_key` if a custom `Devise.secret_key` is not provided.

    This is potentially a breaking change because Devise previously used the following order to find a secret key:

    ```
    app.credentials.secret_key_base > app.secrets.secret_key_base > application.config.secret_key_base > application.secret_key_base
    ```

    Now, it always uses `application.secret_key_base`. Make sure you're using the same secret key after the upgrade; otherwise, previously generated tokens for `recoverable`, `lockable`, and `confirmable` will be invalid.
    [#5645](https://github.com/heartcombo/devise/pull/5645)
  * Change password instructions button label on devise view from `Send me reset password instructions` to `Send me password reset instructions` [#5515](https://github.com/heartcombo/devise/pull/5515)
  * Change `<br>` tags separating form elements to wrapping them in `<p>` tags [#5494](https://github.com/heartcombo/devise/pull/5494)

* enhancements
  * Add Rails 8 support.
    - Routes are lazy-loaded by default in test and development environments now so Devise loads them before `Devise.mappings` call. [#5728](https://github.com/heartcombo/devise/pull/5728)
  * Add Ruby 3.4 support.
  * Reenable Mongoid test suite across all Rails 7+ versions, to ensure we continue supporting it. Changes to dirty tracking to support Mongoid 8.0+. [#5568](https://github.com/heartcombo/devise/pull/5568)
  * Password length validator is changed from

    ```
    validates_length_of :password, within: password_length, allow_blank: true`
    ```

    to

    ```
    validates_length_of :password, minimum: proc { password_length.min }, maximum: proc { password_length.max }, allow_blank: true
    ```

    so it's possible to override `password_length` at runtime. [#5734](https://github.com/heartcombo/devise/pull/5734)

* bug fixes
  * Make `Devise` work without `ActionMailer` when `Zeitwerk` autoloader is used. [#5731](https://github.com/heartcombo/devise/pull/5731)
  * Handle defaults `:from` and `:reply_to` as procs correctly by delegating to Rails [#5595](https://github.com/heartcombo/devise/pull/5595)
  * Use `OmniAuth.config.allowed_request_methods` as routing verbs for the auth path [#5508](https://github.com/heartcombo/devise/pull/5508)
  * Handle `on` and `ON` as true values to check params [#5514](https://github.com/heartcombo/devise/pull/5514)
  * Fix passing `format` option to `devise_for` [#5732](https://github.com/heartcombo/devise/pull/5732)


Please check [4-stable](https://github.com/heartcombo/devise/blob/4-stable/CHANGELOG.md)
for previous changes.
