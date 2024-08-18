### Unreleased

* breaking changes
  * Drop support to Ruby < 2.7
  * Drop support to Rails < 6.0

* enhancements
  * Removed deprecations warning output for `Devise::Models::Authenticatable::BLACKLIST_FOR_SERIALIZATION` (@soartec-lab)
  * Added `Devise.mailer_delivery_method` configuration to enable deferring email delivery with `:deliver_later` [#5610](https://github.com/heartcombo/devise/pull/5610) [@seanpdoyle](https://github.com/seanpdoyle)

Please check [4-stable](https://github.com/heartcombo/devise/blob/4-stable/CHANGELOG.md)
for previous changes.
