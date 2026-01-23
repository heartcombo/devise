### 5.0.0 - 2026-01-23

no changes

### 5.0.0.rc - 2025-12-31

* breaking changes
  * Drop support to Ruby < 2.7
  * Drop support to Rails < 7.0
  * Remove deprecated `:bypass` option from `sign_in` helper, use `bypass_sign_in` instead. [#5803](https://github.com/heartcombo/devise/pull/5803)
  * Remove deprecated `devise_error_messages!` helper, use `render "devise/shared/error_messages", resource: resource` instead. [#5803](https://github.com/heartcombo/devise/pull/5803)
  * Remove deprecated `scope` second argument from `sign_in(resource, :admin)` controller test helper, use `sign_in(resource, scope: :admin)` instead. [#5803](https://github.com/heartcombo/devise/pull/5803)
  * Remove deprecated `Devise::TestHelpers`, use `Devise::Test::ControllerHelpers` instead. [#5803](https://github.com/heartcombo/devise/pull/5803)
  * Remove deprecated `Devise::Models::Authenticatable::BLACKLIST_FOR_SERIALIZATION` [#5598](https://github.com/heartcombo/devise/pull/5598)
  * Remove deprecated `Devise.activerecord51?` method.
  * Remove `SecretKeyFinder` and use `app.secret_key_base` as the default secret key for `Devise.secret_key` if a custom `Devise.secret_key` is not provided.

    This is potentially a breaking change because Devise previously used the following order to find a secret key:

    ```
    app.credentials.secret_key_base > app.secrets.secret_key_base > application.config.secret_key_base > application.secret_key_base
    ```

    Now, it always uses `application.secret_key_base`. Make sure you're using the same secret key after the upgrade; otherwise, previously generated tokens for `recoverable`, `lockable`, and `confirmable` will be invalid.
    [#5645](https://github.com/heartcombo/devise/pull/5645)
  * Change password instructions button label on devise view from `Send me reset password instructions` to `Send me password reset instructions` [#5515](https://github.com/heartcombo/devise/pull/5515)
  * Change `<br>` tags separating form elements to wrapping them in `<p>` tags [#5494](https://github.com/heartcombo/devise/pull/5494)
  * Replace `[data-turbo-cache=false]` with `[data-turbo-temporary]` on `devise/shared/error_messages` partial. This has been [deprecated by Turbo since v7.3.0 (released on Mar 1, 2023)](https://github.com/hotwired/turbo/releases/tag/v7.3.0).

    If you are using an older version of Turbo and the default devise template, you'll need to copy it over to your app and change that back to `[data-turbo-cache=false]`.

* enhancements
  * Add Rails 8 support.
    - Routes are lazy-loaded by default in test and development environments now so Devise loads them before `Devise.mappings` call. [#5728](https://github.com/heartcombo/devise/pull/5728)
  * New apps using Rack 3.1+ will be generated using `config.responder.error_status = :unprocessable_content`, since [`:unprocessable_entity` has been deprecated by Rack](https://github.com/rack/rack/pull/2137).

    Latest versions of [Rails transparently convert `:unprocessable_entity` -> `:unprocessable_content`](https://github.com/rails/rails/pull/53383), and Devise will use that in the failure app to avoid Rack deprecation warnings for apps that are configured with `:unprocessable_entity`. They can also simply change their `error_status` to `:unprocessable_content` in latest Rack versions to avoid the warning.
  * Add Ruby 3.4 and 4.0 support.
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
  * Use `ActiveRecord::SecurityUtils.secure_compare` in `Devise.secure_compare` to match two empty strings correctly. [#4829](https://github.com/heartcombo/devise/pull/4829)
  * Respond with `401 Unauthorized` for non-navigational requests to destroy the session when there is no authenticated resource. [#4878](https://github.com/heartcombo/devise/pull/4878)
  * Fix incorrect grammar of invalid authentication message with capitalized attributes, e.g.: "Invalid Email or password" => "Invalid email or password". (originally introduced by [#4014](https://github.com/heartcombo/devise/pull/4014), released on v4.1.0) [#4834](https://github.com/heartcombo/devise/pull/4834)


Please check [4-stable](https://github.com/heartcombo/devise/blob/4-stable/CHANGELOG.md)
for previous changes.
