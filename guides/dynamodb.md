# Devise with Amazon DynamoDB

Devise ships an ORM adapter for [Amazon DynamoDB](https://aws.amazon.com/dynamodb/).
It runs on either of two Ruby libraries:

| Library | Gem | `config.dynamodb_library` |
| --- | --- | --- |
| [Dynamoid](https://github.com/Dynamoid/dynamoid) (default) | `dynamoid` | `:dynamoid` |
| [aws-record](https://github.com/aws/aws-sdk-ruby-record) | `aws-record` | `:aws_record` |

A working example app is in [`examples/dynamodb_app`](../examples/dynamodb_app).

## Supported modules (V1)

These modules are supported and tested on both libraries:

* `database_authenticatable`
* `rememberable`
* `validatable`
* `confirmable`
* `trackable`
* `recoverable`
* `lockable`

`registerable` and `timeoutable` need nothing from the ORM, so they work as well
and are covered by the test suite. `omniauthable` is ORM-independent too, but
the `find_or_create` logic in your own callbacks is yours to write against your
chosen library. Other ORM-specific extensions are not part of V1.

## Installation

1. Add Devise and one DynamoDB library to your Gemfile:

   ```ruby
   gem "devise"
   gem "dynamoid"      # default library
   # gem "aws-record"  # or this one, with config.dynamodb_library = :aws_record
   ```

2. Configure the DynamoDB connection. With Dynamoid, in
   `config/initializers/dynamoid.rb`:

   ```ruby
   Dynamoid.configure do |config|
     config.namespace = "myapp_#{Rails.env}"
     config.region    = ENV.fetch("AWS_REGION", "us-east-1")
     config.endpoint  = ENV["DYNAMODB_ENDPOINT"] if ENV["DYNAMODB_ENDPOINT"] # e.g. DynamoDB Local
   end
   ```

   With aws-record, configure the AWS SDK (for example
   `Aws.config.update(region: ..., endpoint: ...)`) in an initializer.

3. Tell Rails generators to use the DynamoDB ORM (`config/application.rb`):

   ```ruby
   config.generators { |g| g.orm :dynamodb }
   ```

4. Install Devise:

   ```console
   rails generate devise:install --orm=dynamodb
   ```

   The generated `config/initializers/devise.rb` contains:

   ```ruby
   config.dynamodb_library = :dynamoid   # or :aws_record
   require 'devise/orm/dynamodb'
   ```

   `config.dynamodb_library` must be set **before** the `require`. An unknown
   value raises `ArgumentError`; a missing gem raises a `LoadError` that names it.

5. Generate a model:

   ```console
   rails generate devise User                         # uses config.dynamodb_library
   rails generate dynamodb:devise User --library=aws_record
   ```

   The generator creates `app/models/user.rb` with the Devise fields and
   global secondary indexes (GSIs), or injects them into an existing model after
   `include Dynamoid::Document` / `include Aws::Record`. As with the other ORMs,
   the Trackable, Confirmable and Lockable fields are generated commented out:
   uncomment the fields **and** their GSIs, then add the modules to the
   `devise` line.

6. Create the tables:

   ```console
   bin/rails devise:dynamodb:ping           # checks the endpoint answers
   bin/rails devise:dynamodb:create_tables  # idempotent: existing tables are left alone
   ```

   `bin/rails devise:dynamodb:drop_tables` drops them (it refuses to run in
   production unless `FORCE=true`).

## Indexes

Devise looks records up by these attributes. Declare a GSI on every one you use,
otherwise the lookup falls back to a full table **Scan**, which is slow and
expensive on large tables:

| Attribute | Used by |
| --- | --- |
| `email` (each authentication key) | sign-in, password reset/unlock/confirmation requests, uniqueness |
| `reset_password_token` | recoverable |
| `confirmation_token` | confirmable |
| `unconfirmed_email` | confirmable with `reconfirmable` |
| `unlock_token` | lockable with the `:email` / `:both` unlock strategy |

Lookups by `id` (session and remember-me cookies) are direct key reads.

## Behaviour compared with ActiveRecord

The adapter maps Devise's behaviour 1:1 wherever DynamoDB allows it. In
particular:

* **Email uniqueness.** `validatable` declares
  `validates_uniqueness_of :email, allow_blank: true, case_sensitive: true`, the
  same as with ActiveRecord. DynamoDB models get an AR-compatible
  `validates_uniqueness_of` (also usable as `validates :x, uniqueness: true`)
  that supports `:case_sensitive`, `:scope`, `:allow_nil`, `:allow_blank`,
  `:if`, `:unless`, `:on` and `:message`. The error is `:taken`
  ("has already been taken"). Devise ships that English message for DynamoDB
  apps; your own translation wins.
* **Email case and whitespace.** `case_insensitive_keys` and
  `strip_whitespace_keys` behave exactly as with ActiveRecord (emails are
  downcased and stripped before validation and before lookups).
* **Dirty tracking.** The email-changed and password-changed notifications,
  reconfirmation and token clearing see the same "saved change" information
  inside `after_update` callbacks and after the save as they do with
  ActiveRecord.
* **Lockable** increments `failed_attempts` with an atomic DynamoDB `ADD`, so
  concurrent failed sign-ins are all counted.
* **`update(attributes)` / `update!(attributes)`** behave like ActiveRecord's
  (assign through setters, validate, save).

### Limitations and differences

These cannot be mapped 1:1 because of how DynamoDB works:

1. **Uniqueness is not enforced by the database.** DynamoDB has no unique
   indexes other than the primary key. Like ActiveRecord *without* a unique
   index, the check is a read before the write, so two concurrent sign-ups with
   the same email can both succeed. If you need a hard guarantee, write a
   separate item keyed by the email in a transaction (`TransactWriteItems` with
   `attribute_not_exists`) from your own code.
2. **Case-insensitive uniqueness scans the table.** `case_sensitive: false`
   cannot use an index (DynamoDB comparisons are case-sensitive) and does a full
   Scan. Devise's own validation uses `case_sensitive: true` and downcases
   emails instead, so it is not affected.
3. **Eventual consistency of indexes.** GSI reads are eventually consistent. A
   record written a moment ago may not yet be found by email or token. In
   practice this affects only lookups within milliseconds of a write.
4. **No transactions or `after_commit`.** Confirmable's mails, which ActiveRecord
   sends `after_commit`, are sent from `after_create` / `after_update` (as with
   Mongoid). A failure after the item was written cannot be rolled back.
   `send_devise_notification` overrides that queue mails until `after_commit`
   must use `after_save` instead.
5. **Empty strings.** Dynamoid stores `""` as `null` by default
   (`store_empty_string_as_nil`), so a blank attribute reads back as its
   default (`""` for `email`/`encrypted_password` in the generated model) or
   `nil`. DynamoDB also rejects empty strings as GSI key values, so lookups for
   a blank value scan instead of querying the index.
6. **Lookups on non-indexed attributes scan the table**, including
   `find_first`/`find_all` conditions on attributes without a GSI (for example
   custom authentication keys you did not index). Ordering, `limit` and
   `offset` in `to_adapter.find_all` are applied in memory.
7. **`Model.count`** with Dynamoid uses `DescribeTable`'s item count, which
   DynamoDB refreshes only every few hours. Do not rely on it for exact counts.
8. **No `update_all`/`where(...).update_all`.** Bulk updates have to be written
   with the library's own API.
9. **Not part of V1:** `validates_uniqueness_of`'s `:conditions` option, and
   generator migrations (DynamoDB has no schema migrations: add a GSI with the
   AWS console/CLI or recreate the table).

### Library-specific notes

**Dynamoid**

* Devise's compatibility methods (`validates_uniqueness_of`, AR-style
  `update`/`update!`, `increment_counter`, `find_by`, `to_adapter`) are added
  only to models that call `devise`. Dynamoid's block form of `update`
  (atomic updates) keeps working when a block is given.
* Dynamoid adds `id` (a UUID string), `created_at` and `updated_at` itself.

**aws-record**

aws-record is a thin mapper without ActiveModel support, so Devise adds what
it needs:

* Every class that includes `Aws::Record` (not just Devise models) gets
  ActiveModel naming, validations, callbacks (`before_/after_/around_` for
  `save`, `create`, `update`, `destroy`), conversion and JSON serialization,
  plus `attribute?` query methods, `base_class`, and automatic attribute
  inheritance for plain Ruby subclasses. If you already add these to your
  aws-record models yourself, check that they do not conflict.
* Devise models also get AR-style `save`/`save!` (with `validate: false`),
  `update`/`update!`, `update_attribute`, `destroy`, `reload`, `changed?`,
  `[]`/`[]=`, `create`/`create!`, `find(id)` (raises
  `Aws::Record::Errors::NotFound`), `find_by` and `increment_counter`.
* Declare `string_attr :id, hash_key: true`; Devise assigns a UUID on first
  save. Declare `created_at`/`updated_at` if you want timestamps; Devise fills
  them in when present (the generator adds them).
* Use `time_attr ..., formatter: Devise::Orm::Dynamodb::AwsRecord::PreciseTime`
  for time attributes (the generator does). aws-record's `epoch_time_attr` and
  default `time_attr` formats drop sub-second precision, which breaks
  remember-me cookie validation.
* Tables are created with on-demand billing (`PAY_PER_REQUEST`) by
  `devise:dynamodb:create_tables`. Use `Aws::Record::TableConfig` yourself for
  provisioned capacity.
* `save!` raises `Aws::Record::Errors::ValidationError`, where ActiveRecord
  raises `ActiveRecord::RecordInvalid`.

## Testing your app

Run your tests against [DynamoDB Local](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DynamoDBLocal.html)
(`docker run -p 8000:8000 amazon/dynamodb-local`) and point the library's
endpoint at `http://localhost:8000`. `Devise::Orm::Dynamodb::Tables` helps in
test setup:

```ruby
Devise::Orm::Dynamodb::Tables.create_all            # {created: [...], existing: [...]}
Devise::Orm::Dynamodb::Tables.truncate(User)        # delete every item
Devise::Orm::Dynamodb::Tables.drop_all
Devise::Orm::Dynamodb::Tables.ping                  # raises if unreachable
```

## Running Devise's own test suite on DynamoDB

```console
docker run -d -p 8000:8000 amazon/dynamodb-local     # or: npx dynalite --port 8000
DEVISE_ORM=dynamodb bin/test                          # Dynamoid
DEVISE_ORM=dynamodb DEVISE_DYNAMODB_LIBRARY=aws_record bin/test
```

`DYNAMODB_ENDPOINT` overrides the endpoint (default `http://localhost:8000`).
