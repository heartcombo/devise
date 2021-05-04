### unreleased

### 4.8.0 - 2021-04-29

* enhancements
  * Devise now enables the upgrade of OmniAuth 2+. Previously Devise would raise an error if you'd try to upgrade. Please note that OmniAuth 2 is considered a security upgrade and recommended to everyone. You can read more about the details (and possible necessary changes to your app as part of the upgrade) in [their release notes](https://github.com/omniauth/omniauth/releases/tag/v2.0.0). [Devise's OmniAuth Overview wiki](https://github.com/heartcombo/devise/wiki/OmniAuth:-Overview) was also updated to cover OmniAuth 2.0 requirements.
    - Note that the upgrade required Devise shared links that initiate the OmniAuth flow to be changed to `method: :post`, which is now a requirement for OmniAuth, part of the security improvement. If you have copied and customized the Devise shared links partial to your app, or if you have other links in your app that initiate the OmniAuth flow, they will have to be updated to use `method: :post`, or changed to use buttons (e.g. `button_to`) to work with OmniAuth 2. (if you're using links with `method: :post`, make sure your app has `rails-ujs` or `jquery-ujs` included in order for these links to work properly.)
    - As part of the OmniAuth 2.0 upgrade you might also need to add the [`omniauth-rails_csrf_protection`](https://github.com/cookpad/omniauth-rails_csrf_protection) gem to your app if you don't have it already. (and you don't want to roll your own code to verify requests.) Check the OmniAuth v2 release notes for more info.
  * Introduce `Lockable#reset_failed_attempts!` model method to reset failed attempts counter to 0 after the user signs in.
    - This logic existed inside the lockable warden hook and is triggered automatically after the user signs in. The new model method is an extraction to allow you to override it in the application to implement things like switching to a write database if you're using the new multi-DB infrastructure from Rails for example, similar to how it's already possible with `Trackable#update_tracked_fields!`.
  * Add support for Ruby 3.
  * Add support for Rails 6.1.
  * Move CI to GitHub Actions.

* deprecations
  * `Devise::Models::Authenticatable::BLACKLIST_FOR_SERIALIZATION` is deprecated in favor of `Devise::Models::Authenticatable::UNSAFE_ATTRIBUTES_FOR_SERIALIZATION` (@hanachin)

### 4.7.3 - 2020-09-20

* bug fixes
  * Do not modify `:except` option given to `#serializable_hash`. (by @dpep)
  * Fix thor deprecation when running the devise generator. (by @deivid-rodriguez)
  * Fix hanging tests for streaming controllers using Devise. (by @afn)

### 4.7.2 - 2020-06-10

* enhancements
  * Increase default stretches to 12 (by @sergey-alekseev)
  * Ruby 2.7 support (kwarg warnings removed)

* bug fixes
  * Generate scoped views with proper scoped errors partial (by @shobhitic)
  * Allow to set scoped `already_authenticated` error messages (by @gurgelrenan)

### 4.7.1 - 2019-09-06

* bug fixes
  * Fix an edge case where records with a blank `confirmation_token` could be confirmed (by @tegon)
  * Fix typo inside `update_needs_confirmation` i18n key (by @lslm)

### 4.7.0 - 2019-08-19

* enhancements
  * Support Rails 6.0
  * Update CI to rails 6.0.0.beta3 (by @tunnes)
  * refactor method name to be more consistent (by @saiqulhaq)
  * Fix rails 6.0.rc1 email uniqueness validation deprecation warning (by @Vasfed)

* bug fixes
  * Add `autocomplete="new-password"` to `password_confirmation` fields (by @ferrl)
  * Fix rails_51_and_up? method for Rails 6.rc1 (by @igorkasyanchuk)

### 4.6.2 - 2019-03-26

* bug fixes
  * Revert "Set `encrypted_password` to `nil` when `password` is set to `nil`" since it broke backward compatibility with existing applications. See more on https://github.com/heartcombo/devise/issues/5033#issuecomment-476386275 (by @mracos)

### 4.6.1 - 2019-02-11

* bug fixes
  * Check if `root_path` is defined with `#respond_to?` instead of `#present` (by @tegon)

### 4.6.0 - 2019-02-07

* enhancements
  * Allow to skip email and password change notifications (by @iorme1)
  * Include the use of `nil` for `allow_unconfirmed_access_for` in the docs (by @joaumg)
  * Ignore useless files into the `.gem` file (by @huacnlee)
  * Explain the code that prevents enumeration attacks inside `Devise::Strategies::DatabaseAuthenticatable` (by @tegon)
  * Refactor the `devise_error_messages!` helper to render a partial (by @prograhamer)
  * Add an option (`Devise.sign_in_after_change_password`) to not automatically sign in a user after changing a password (by @knjko)

* bug fixes
  * Fix missing comma in Simple Form generator (by @colinross)
  * Fix error with migration generator in Rails 6 (by @oystersauce8)
  * Set `encrypted_password` to `nil` when `password` is set to `nil` (by @sivagollapalli)
  * Consider whether the request supports flash messages inside `Devise::Controllers::Helpers#is_flashing_format?` (by @colinross)
  * Fix typo inside `Devise::Generators::ControllersGenerator` (by @kopylovvlad)
  * Sanitize parameters inside `Devise::Models::Authenticatable#find_or_initialize_with_errors` (by @rlue)
  * `#after_database_authentication` callback was not called after authentication on password reset (by @kanmaniselvan)
  * Fix corner case when `#confirmation_period_valid?` was called at the same second as `confirmation_sent_at` was set. Mostly true for date types that only have second precisions. (by @stanhu)
  * Fix unclosed `li` tag in `error_messages` partial (by @mracos)
  * Fix Routes issue when devise engine is mounted in another engine on Rails versions lower than 5.1 (by @a-barbieri)
  * Make `#increment_failed_attempts` concurrency safe (by @tegon)
  * Apply Test Helper fix to Rails 6.0 as well as 5.x (by @matthewrudy)


* deprecations
  * The second argument of `DatabaseAuthenticatable`'s `#update_with_password` and `#update_without_password` is deprecated and will be removed in the next major version. It was added to support a feature deprecated in Rails 4, so you can safely remove it from your code. (by @ihatov08)
  * The `DeviseHelper.devise_error_messages!` is deprecated and will be removed in the next major version. Use the `devise/shared/error_messages` partial instead. (by @mracos)

### 4.5.0 - 2018-08-15

* enhancements
  * Use `before_action` instead of `before_filter` (by @edenthecat)
  *  Allow people to extend devise failure app, through invoking `ActiveSupport.run_load_hooks` once `Devise::FailureApp` is loaded (by @wnm)
  * Use `update` instead of `update_attributes` (by @koic)
  * Split IP resolution from `update_tracked_fields` (by @mckramer)
  * upgrade dependencies for rails and responders (by @lancecarlson)
  * Add `autocomplete="new-password"` to new password fields (by @gssbzn)
  * Add `autocomplete="current-password"` to current password fields (by @gssbzn)
  * Remove redundant `self` from `database_authenticatable` module (by @abhishekkanojia)
  * Update `simple_form` templates with changes from https://github.com/heartcombo/devise/commit/16b3d6d67c7e017d461ea17ed29ea9738dc77e83 and https://github.com/heartcombo/devise/commit/6260c29a867b9a656f1e1557abe347a523178fab (by @gssbzn)
  * Remove `:trackable` from the default modules in the generators, to be more GDPR-friendly (by @fakenine)

* bug fixes
  * Use same string on failed login regardless of whether account exists when in paranoid mode (by @TonyMK9068)
  * Fix error when params is not a hash inside `Devise::ParameterSanitizer` (by @b0nn1e)
  * Look for `secret_key_base` inside `Rails.application` (by @gencer)
  * Ensure `Devise::ParameterFilter` does not add missing keys when called with a hash that has a `default` / `default_proc`
configured (by @joshpencheon)
  * Adds `is_navigational_format?` check to `after_sign_up_path_for` to keep consistency (by @iorme1)

### 4.4.3 - 2018-03-17

* bug fixes
  * Fix undefined method `rails5?` for Devise::Test:Module (by @tegon)
  * Fix: secret key was being required to be set inside credentials on Rails 5.2 (by @tegon)

### 4.4.2 - 2018-03-15

* enhancements
  * Support for :credentials on Rails v5.2.x. (by @gencer)
  * Improve documentation about the test suite. (by @tegon)
  * Test with Rails 5.2.rc1 on Travis. (by @jcoyne)
  * Allow test with Rails 6. (by @Fudoshiki)
  * Creating a new section for controller configuration on `devise.rb` template (by @Danilo-Araujo-Silva)

* bug fixes
  * Preserve content_type for unauthenticated tests (by @gmcnaughton)
  * Check if the resource is persisted in `update_tracked_fields!` instead of performing validations (by @tegon)
  * Revert "Replace log_process_action to append_info_to_payload" (by @tegon)

### 4.4.1 - 2018-01-23

* bug fixes
  * Ensure Gemspec is loaded as utf-8. (by @segiddins)
  * Fix `ActiveRecord` check on `Confirmable`. (by @tegon)
  * Fix `signed_in?` docs without running auth hooks. by (@machty)

### 4.4.0 - 2017-12-29

* enhancements
  * Add `frozen_string_literal` pragma comment to all Ruby files. (by @pat)
  * Use `set_flash_method!` instead of `set_flash_method` in `Devise::OmniauthCallbacksController#failure`. (by @saichander17)
  * Clarify how `store_location_for` modifies URIs. (by @olivierlacan)
  * Move `failed_attempts` increment into its own function. by (@mobilutz)
  * Add `autocomplete="email"` to email fields. by (@MikeRogers0)
  * Add the ability to change the default migrations path introduced in Rails 5.0.3.  (by @alexhifer)
  * Delete unnecessary condition for helper method. (by @davydovanton)
  * Support `id: :uuid` option for migrations. (by @filip373)

* bug fixes
  * Fix syntax for MRI 2.5.0. (by @pat)
  * Validations were being ignored on singup in the `Trackable#update_tracked_fields!` method. (by @AshleyFoster)
  * Do not modify options for `#serializable_hash`. (by @guigs)
  * Email confirmations were being sent on sign in/sign out for application using `mongoid` and `mongoid-paperclip` gems. This is because previously we were checking if a model is from Active Record by checking if the method `after_commit` was defined - since `mongoid` doesn' have one - but `mongoid-paperclip` gem does define one, which cause this issue. (by @fjg)

### 4.3.0 - 2017-05-14

* Enhancements
  * Dependency support added for Rails 5.1.x.

### 4.2.1 - 2017-03-15

* removals
  * `Devise::Mailer#scope_name` and `Devise::Mailer#resource` are now protected
    methods instead of public.
* bug fixes
  * Attempt to reset password without the password field in the request now results in a `:blank` validation error.
    Before this change, Devise would accept the reset password request and log the user in, without validating/changing
    the password. (by @victor-am)
  * Confirmation links now expire based on UTC time, working properly when using different timezones. (by @jjuliano)
* enhancements
  * Notify the original email when it is changed with a new `Devise.send_email_changed_notification` setting.
    When using `reconfirmable`, the notification will be sent right away instead of when the unconfirmed email is confirmed.
    (original change by @ethirajsrinivasan)

### 4.2.0 - 2016-07-01

* removals
  * Remove the deprecated `Devise::ParameterSanitizer` API from Devise 3.
    Please use the `#permit` and `#sanitize` methods over `#for`.
  * Remove the deprecated OmniAuth URL helpers. Use the fully qualified helpers
    (`user_facebook_omniauth_authorize_path`) over the scope based helpers
    ( `user_omniauth_authorize_path(:facebook)`).
  * Remove the `Devise.bcrypt` method, use `Devise::Encryptor.digest` instead.
  * Remove the `Devise::Models::Confirmable#confirm!` method, use `confirm` instead.
  * Remove the `Devise::Models::Recoverable#reset_password!` method, use `reset_password` instead.
  * Remove the `Devise::Models::Recoverable#after_password_reset` method.
* bug fixes
  * Fix an `ActionDispatch::IllegalStateError` when testing controllers with Rails 5 rc 2(by @hamadata).
  * Use `ActiveSupport.on_load` hooks to include Devise on `ActiveRecord` and `Mongoid`,
    avoiding autoloading these constants too soon (by @lucasmazza, @rafaelfranca).
* enhancements
  * Display the minimum password length on `registrations/edit` view (by @Yanchek99).
  * You can disable Devise's routes reloading on boot by through the `reload_routes = false` config.
    This can reduce the time taken to boot the application but it might trigger
    some errors if you application (mostly your controllers) requires that
    Devise mappings be loaded during boot time (by @sidonath).
  * Added `Devise::Test::IntegrationHelpers` to bypass the sign in process using
    Warden test API (by @lucasmazza).
  * Define `inspect` in `Devise::Models::Authenticatable` to help ensure password hashes
    aren't included in exceptions or otherwise accidentally serialized (by @tkrajcar).
  * Add missing support of `Rails.application.config.action_controller.relative_url_root` (by @kosdiamantis).
* deprecations
  * `Devise::TestHelpers` is deprecated in favor of `Devise::Test::ControllerHelpers`
    (by @lucasmazza).
  * The `sign_in` test helper has changed to use keyword arguments when passing
    a scope. `sign_in :admin, users(:alice)` should be rewritten as
    `sign_in users(:alice), scope: :admin` (by @lucasmazza).
  * The option `bypass` of `Devise::Controllers::SignInOut#sign_in` method is
    deprecated in favor of `Devise::Controllers::SignInOut#bypass_sign_in`
    method (by @ulissesalmeida).

### 4.1.1 - 2016-05-15

* bug fixes
  * Fix overwriting the remember_token when a valid one already exists (by @ralinchimev).

### 4.1.0

* bug fixes
  * Fix race condition of sending the confirmation instructions e-mail using background jobs.
    Using the previous `after_create` callback, the e-mail can be sent before
    the record be committed on database, generating a `ActiveRecord::NotFound` error.
    Now the confirmation e-mail will be only sent after the database commit,
    using the `after_commit` callback.
    It may break your test suite on Rails 4 if you are testing the sent e-mails
    or enqueued jobs using transactional fixtures enabled or `DatabaseCleaner` with `transaction` strategy.
    You can easily fix your test suite using the gem
    [test_after_commit](https://github.com/grosser/test_after_commit). For example, put in your Gemfile:

    ```ruby
      gem 'test_after_commit', :group => :test
    ```

    On Rails 5 `after_commit` callbacks are triggered even using transactional
    fixtures, then this fix will not break your test suite. If you are using `DatabaseCleaner` with the `deletion` or `truncation` strategies it may not break your tests. (by @allenwq)
  * Fix strategy checking in `Lockable#unlock_strategy_enabled?` for `:none` and
  `:undefined` strategies. (by @f3ndot)
* features
  * Humanize authentication keys in failure flash message (by @byzg)
    When you are configuring the translations of `devise.failure.invalid`, the
    `authentication_keys` is translated now.
* deprecations
  * Remove code supporting old session serialization format (by @fphilipe).
  * Now the `email_regexp` default uses a more permissive regex:
    `/\A[^@\s]+@[^@\s]+\z/` (by @kimgb)
  * Now the `strip_whitespace_keys` default is `[:email]` (by @ulissesalmeida)
  * Now the `reconfirmable` default is `true` (by @ulissesalmeida)
  * Now the `skip_session_storage` default is `[:http_auth]` (by @ulissesalmeida)
  * Now the `sign_out_via` default is `:delete` (by @ulissesalmeida)
* improvements
  * Avoids extra computation of friendly token for confirmation token (by @sbc100)

### 4.0.3 - 2016-05-15

  * bug fixes
    * Fix overwriting the remember_token when a valid one already exists (by @ralinchimev).

### 4.0.2 - 2016-05-02

* bug fixes
  * Fix strategy checking in `Lockable#unlock_strategy_enabled?` for `:none`
    and `:undefined` strategies. (by @f3ndot)

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
    and provider specific routes are defined instead, so route helpers like `user_omniauth_authorize_path(:github)` are deprecated in favor of `user_github_omniauth_authorize_path`.
    You can still use `omniauth_authorize_path(:user, :github)` if you need to
    call the helpers dynamically.

### 4.0.0.rc1 - 2016-02-01

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

    You can check more examples and explanations on the [README section](README.md#strong-parameters)
    and on the [ParameterSanitizer docs](lib/devise/parameter_sanitizer.rb).

Please check [3-stable](https://github.com/heartcombo/devise/blob/3-stable/CHANGELOG.md)
for previous changes.
