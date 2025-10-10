### Unreleased

* breaking changes
  * Drop support to Ruby < 2.7
  * Drop support to Rails < 6.0
  * Remove `SecretKeyFinder` and use `app.secret_key_base` as the default secret key for `Devise.secret_key` if a custom `Devise.secret_key` is not provided.

    This is potentially a breaking change because Devise previously used the following order to find a secret key:

    ```
    app.credentials.secret_key_base > app.secrets.secret_key_base > application.config.secret_key_base > application.secret_key_base
    ```

    Now, it always uses `application.secret_key_base`. Make sure you're using the same secret key after the upgrade; otherwise, previously generated tokens for `recoverable`, `lockable`, and `confirmable` will be invalid.
    https://github.com/heartcombo/devise/pull/5645

* enhancements
  * Removed deprecations warning output for `Devise::Models::Authenticatable::BLACKLIST_FOR_SERIALIZATION` (@soartec-lab)
  * Add Rails 8 support.
    - Routes are lazy-loaded by default in test and development environments now so Devise loads them before `Devise.mappings` call.
  * Password length validator is changed from

    ```
    validates_length_of :password, within: password_length, allow_blank: true`
    ```

    to

    ```
    validates_length_of :password, minimum: proc { password_length.min }, maximum: proc { password_length.max }, allow_blank: true
    ```

    so it's possible to override `password_length` at runtime. (@manojmj92)
* bug fixes
  * Make `Devise` work without `ActionMailer` when `Zeitwerk` autoloader is used.

Please check [4-stable](https://github.com/heartcombo/devise/blob/4-stable/CHANGELOG.md)
for previous changes.
