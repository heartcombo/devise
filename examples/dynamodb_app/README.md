# Devise on DynamoDB – sample application

A minimal Rails application using Devise with Amazon DynamoDB, showing the
7 modules supported on DynamoDB: `database_authenticatable`, `registerable`
(plus `rememberable`, `validatable`, `confirmable`, `trackable`,
`recoverable` and `lockable`).

The same `User` model is implemented with both supported libraries:

* [`app/models/dynamoid/user.rb`](app/models/dynamoid/user.rb) – Dynamoid (default)
* [`app/models/aws_record/user.rb`](app/models/aws_record/user.rb) – aws-record

A real application only needs one of them; `app/models/user.rb` loads the one
matching `Devise.dynamodb_library`.

## Running it

1. Start DynamoDB Local (or point `DYNAMODB_ENDPOINT` to any compatible endpoint):

   ```sh
   docker run -p 8000:8000 amazon/dynamodb-local
   ```

2. Install the gems and create the tables:

   ```sh
   bundle install
   bin/rails devise:dynamodb:create_tables
   bin/rails devise:dynamodb:check_indexes   # optional: confirms no lookup needs a table Scan
   ```

3. Start the server and open http://localhost:3000:

   ```sh
   bin/rails server
   ```

   Confirmation, password reset and unlock emails aren't sent. Their links
   are printed in `log/development.log`.

To use aws-record instead of Dynamoid, set `DEVISE_DYNAMODB_LIBRARY=aws_record`
for every command above (or set `config.dynamodb_library = :aws_record` in
`config/initializers/devise.rb`).

To use AWS instead of DynamoDB Local, set `DYNAMODB_ENDPOINT=` (empty),
`AWS_REGION`, and AWS credentials the usual way (environment variables,
`~/.aws/credentials` or an IAM role).

## Tests

`test/integration/authentication_flow_test.rb` walks through sign up,
confirmation, sign in/out, tracking, remember me, password reset, locking,
unlocking and reconfirmation:

```sh
bin/rails test
DEVISE_DYNAMODB_LIBRARY=aws_record bin/rails test
```

## How it was built

```sh
rails new dynamodb_app --minimal --skip-active-record
# Gemfile: gem "devise", gem "dynamoid" (or gem "aws-record")
# config/application.rb: config.generators.orm :dynamodb
bin/rails generate devise:install     # requires 'devise/orm/dynamodb'
bin/rails generate devise User        # creates a Dynamoid model, no migration
```

The connection settings are in [`config/initializers/dynamodb.rb`](config/initializers/dynamodb.rb).
