### Unreleased

* breaking changes
  * Drop support to Ruby < 2.7
  * Drop support to Rails < 6.0

* enhancements
  * Removed deprecations warning output for `Devise::Models::Authenticatable::BLACKLIST_FOR_SERIALIZATION` (@soartec-lab)
  * Reenable Mongoid test suite across all Rails 6+ versions, to ensure we continue supporting it. Changes to dirty tracking to support Mongoid 8.0+. [#5568](https://github.com/heartcombo/devise/pull/5568)

Please check [4-stable](https://github.com/heartcombo/devise/blob/4-stable/CHANGELOG.md)
for previous changes.
