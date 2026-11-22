# frozen_string_literal: true

require 'test_helper'

if [:dynamoid, :aws_record].include?(DEVISE_ORM)
  require 'devise/orm/dynamodb/tasks'

  # Behaviour specific to the DynamoDB integration (Dynamoid and aws-record).
  # The rest of the suite covers the 7 supported modules end to end.
  class DynamodbAdapterTest < ActiveSupport::TestCase
    test 'model is detected as a DynamoDB model' do
      assert Devise::Orm.dynamodb?(User)
      assert_equal DEVISE_ORM == :dynamoid, !!Devise::Orm.dynamoid?(User)
      assert_equal DEVISE_ORM == :aws_record, !!Devise::Orm.aws_record?(User)
      assert_not Devise::Orm.active_record?(User)
    end

    test 'to_adapter returns the DynamoDB adapter' do
      expected = DEVISE_ORM == :dynamoid ? Devise::Orm::Dynamodb::DynamoidAdapter : Devise::Orm::Dynamodb::AwsRecordAdapter
      assert_instance_of expected, User.to_adapter
    end

    test 'column_names lists the declared attributes' do
      columns = User.to_adapter.column_names
      assert_includes columns, "email"
      assert_includes columns, "encrypted_password"
      assert_includes columns, "failed_attempts"
    end

    test 'get and get! find records by partition key or to_key' do
      user = create_user
      assert_equal user, User.to_adapter.get(user.id)
      assert_equal user, User.to_adapter.get(user.to_key)
      assert_equal user, User.to_adapter.get!(user.to_key)
    end

    test 'get returns nil and get! raises when no record exists' do
      assert_nil User.to_adapter.get("missing")
      assert_nil User.to_adapter.get(nil)
      assert_raise(Devise::Orm::Dynamodb::RecordNotFound) { User.to_adapter.get!("missing") }
    end

    test 'find_first finds records by an indexed attribute' do
      user = create_user
      assert_equal user, User.to_adapter.find_first(email: user.email)
      assert_equal user, User.to_adapter.find_first(conditions: { email: user.email })
      assert_nil User.to_adapter.find_first(email: "nobody@example.com")
    end

    test 'find_first finds records by a non indexed attribute' do
      user = create_user
      user.update_attribute(:reset_password_token, "abc")
      assert_equal user, User.to_adapter.find_first(reset_password_token: "abc")
      assert_nil User.to_adapter.find_first(reset_password_token: "xyz")
    end

    test 'find_first combines conditions' do
      user = create_user(username: "first")
      create_user(username: "second")
      assert_equal user, User.to_adapter.find_first(email: user.email, username: "first")
      assert_nil User.to_adapter.find_first(email: user.email, username: "second")
    end

    test 'find_first with id condition uses the partition key' do
      user = create_user
      assert_equal user, User.to_adapter.find_first(id: user.id)
      assert_equal user, User.to_adapter.find_first(id: user.id, email: user.email)
      assert_nil User.to_adapter.find_first(id: user.id, email: "other@example.com")
    end

    test 'find_first with nil condition matches missing attributes' do
      user = create_user
      user.update_attribute(:unlock_token, "token")
      other = create_user
      assert_equal other, User.to_adapter.find_first(email: other.email, unlock_token: nil)
      assert_nil User.to_adapter.find_first(email: user.email, unlock_token: nil)
    end

    test 'find_all supports order, limit and offset' do
      users = %w(b c a).map { |name| create_user(username: name) }
      sorted = User.to_adapter.find_all(order: :username)
      assert_equal %w(a b c), sorted.map(&:username)
      assert_equal %w(c b a), User.to_adapter.find_all(order: [:username, :desc]).map(&:username)
      assert_equal %w(b), User.to_adapter.find_all(order: :username, limit: 1, offset: 1).map(&:username)
      assert_equal users.size, User.to_adapter.find_all.size
    end

    test 'find_first supports order' do
      create_user(username: "b")
      create_user(username: "a")
      assert_equal "a", User.to_adapter.find_first(order: :username).username
      assert_equal "b", User.to_adapter.find_first(order: [:username, :desc]).username
    end

    test 'create! creates a record' do
      user = User.to_adapter.create!(valid_attributes)
      assert user.persisted?
      assert_equal user, User.to_adapter.get(user.id)
    end

    test 'destroy removes a record' do
      user = create_user
      assert User.to_adapter.destroy(user)
      assert_nil User.to_adapter.get(user.id)
    end

    test 'destroy ignores objects of other classes' do
      admin = create_admin
      assert_nil User.to_adapter.destroy(admin)
      assert Admin.to_adapter.get(admin.id)
    end
  end

  class DynamodbModelTest < ActiveSupport::TestCase
    test 'new records get a generated partition key on save' do
      user = new_user
      assert user.save
      assert user.id.present?
      assert user.persisted?
    end

    test 'save(validate: false) skips validations' do
      user = new_user(email: "invalid")
      assert_not user.save
      assert user.save(validate: false)
    end

    test 'update assigns attributes, validates and saves' do
      user = create_user
      assert user.update(username: "renamed")
      assert_equal "renamed", user.reload.username
      assert_not user.update(email: "invalid")
      assert_equal "renamed", user.reload.username
    end

    test 'update refuses unpermitted parameters' do
      user = create_user
      params = ActionController::Parameters.new(username: "hacker")
      assert_raise(ActiveModel::ForbiddenAttributesError) { user.update(params) }
      assert_raise(ActiveModel::ForbiddenAttributesError) { User.new(params) }
      assert user.update(params.permit(:username))
      assert_equal "hacker", user.reload.username
    end

    test 'update! raises when invalid' do
      user = create_user
      assert_raise(DEVISE_ORM == :dynamoid ? Dynamoid::Errors::DocumentNotValid : Devise::Orm::Dynamodb::RecordInvalid) do
        user.update!(email: "invalid")
      end
    end

    test 'dirty tracking for devise' do
      user = create_user
      assert_not user.devise_will_save_change_to_email?
      user.email = "changed@example.com"
      assert user.devise_will_save_change_to_email?
      assert user.devise_respond_to_and_will_save_change_to_attribute?(:email)
      assert_not user.devise_respond_to_and_will_save_change_to_attribute?(:encrypted_password)
      assert_not user.devise_respond_to_and_will_save_change_to_attribute?(:not_an_attribute)
    end

    test 'devise_email_in_database returns the persisted email' do
      user = create_user
      original = user.email
      user.email = "changed@example.com"
      assert_equal original, user.devise_email_in_database
    end

    test 'saved changes are available after save' do
      user = create_user
      original = user.email
      user.update(email: "changed@example.com")
      assert user.devise_saved_change_to_email?
      assert_equal original, user.devise_email_before_last_save
      assert_not user.devise_saved_change_to_encrypted_password?

      user.update(password: "newpassword", password_confirmation: "newpassword")
      assert user.devise_saved_change_to_encrypted_password?
      assert_not user.devise_saved_change_to_email?
    end

    test 'saved changes are available in after_update callbacks' do
      klass = Class.new(User) do
        attr_reader :seen
        def self.name; "User"; end
        after_update { @seen = [devise_saved_change_to_email?, devise_email_before_last_save] }
      end
      user = klass.create!(valid_attributes)
      original = user.email
      user.update(email: "callback@example.com")
      assert_equal [true, original], user.seen
    end

    test 'devise_unconfirmed_email_will_change! forces the attribute to be saved' do
      admin = create_admin
      admin.update(email: "new@example.com")
      assert_equal "new@example.com", admin.unconfirmed_email

      admin = Admin.find(admin.id)
      admin.devise_unconfirmed_email_will_change!
      assert admin.unconfirmed_email_changed?
    end

    test 'increment_counter atomically increments a counter' do
      user = create_user
      User.increment_counter(:failed_attempts, user.id)
      User.increment_counter(:failed_attempts, user.id)
      assert_equal 2, user.reload.failed_attempts
    end

    test 'increment_failed_attempts does not lose concurrent increments' do
      user = create_user
      stale = User.find(user.id)
      user.increment_failed_attempts
      stale.increment_failed_attempts
      assert_equal 2, stale.failed_attempts
      assert_equal 2, user.reload.failed_attempts
    end

    test 'unsafe attributes are not serialized' do
      user = create_user
      json = user.as_json["user"]
      assert_equal user.email, json["email"]
      assert_not json.key?("encrypted_password")
      assert_no_match(/encrypted_password/, user.inspect)
      assert_no_match(/#{Regexp.escape(user.encrypted_password)}/, user.to_json)
    end

    test 'records loaded twice are equal and hash the same' do
      user = create_user
      copy = User.find(user.id)
      assert_equal user, copy
      assert user.eql?(copy)
      assert_equal 1, [user, copy].uniq.size
      assert_not_equal user, create_user
    end

    test 'missing records respond with 404' do
      assert_equal :not_found, ActionDispatch::ExceptionWrapper.rescue_responses["Devise::Orm::Dynamodb::RecordNotFound"]
    end

    test 'to_key and to_param use the partition key' do
      user = create_user
      assert_equal [user.id], user.to_key
      assert_equal user.id, user.to_param
    end

    test 'reload returns the persisted state' do
      user = create_user
      user.username = "unsaved"
      user.reload
      assert_equal "usertest", user.username
      assert_not user.changed?
    end

    test 'subclasses share the table and devise configuration' do
      subclass = Class.new(User) { def self.name; "User"; end }
      record = subclass.create!(valid_attributes)
      assert record.persisted?
      assert_equal record.id, User.to_adapter.get(record.id).id
    end
  end

  class DynamodbUniquenessValidatorTest < ActiveSupport::TestCase
    test 'validatable rejects a duplicated email' do
      existing = create_user
      user = new_user(email: existing.email)
      assert user.invalid?
      assert_equal 'has already been taken', user.errors[:email].join
    end

    test 'validatable compares emails case-insensitively through case_insensitive_keys' do
      existing = create_user
      user = new_user(email: existing.email.upcase)
      assert user.invalid?
      assert_equal 'has already been taken', user.errors[:email].join
    end

    test 'a record does not conflict with itself' do
      user = create_user
      user.email = user.email.dup
      assert user.valid?
      user.username = "changed"
      assert user.save
    end

    test 'the check only runs when the email changes' do
      user = create_user
      Devise::Orm::Dynamodb::UniquenessValidator.any_instance.expects(:validate_each).never
      user.username = "changed"
      assert user.valid?
    end

    test 'scope, case_sensitive and conditions options' do
      klass = Class.new(User) do
        def self.name; "User"; end
        clear_validators!
        validates_uniqueness_of :username, scope: :facebook_token, case_sensitive: false,
          conditions: -> { email.present? }
      end
      klass.create!(valid_attributes(username: "Taken", facebook_token: "a"))

      assert klass.new(valid_attributes(username: "taken", facebook_token: "a")).invalid?
      assert klass.new(valid_attributes(username: "taken", facebook_token: "b")).valid?
      assert klass.new(valid_attributes(username: "other", facebook_token: "a")).valid?
    end

    test 'allow_blank skips the check' do
      klass = Class.new(User) do
        def self.name; "User"; end
        clear_validators!
        validates_uniqueness_of :username, allow_blank: true
      end
      klass.new(valid_attributes(username: nil)).save(validate: false)
      assert klass.new(valid_attributes(username: nil)).valid?
    end
  end

  class DynamodbLibrarySelectionTest < ActiveSupport::TestCase
    test 'supported libraries' do
      assert_equal [:dynamoid, :aws_record], Devise::DYNAMODB_LIBRARIES
    end

    test 'the configured library is loaded' do
      assert_equal DEVISE_ORM, Devise.dynamodb_library
    end

    test 'DEVISE_DYNAMODB_LIBRARY takes precedence over the setting' do
      ENV["DEVISE_DYNAMODB_LIBRARY"] = DEVISE_ORM.to_s
      swap Devise, dynamodb_library: :cassandra do
        load File.expand_path('../../lib/devise/orm/dynamodb.rb', __FILE__)
        assert_equal DEVISE_ORM, Devise.dynamodb_library
      end
    ensure
      ENV.delete("DEVISE_DYNAMODB_LIBRARY")
    end

    test 'raises for an unknown library' do
      swap Devise, dynamodb_library: :cassandra do
        error = assert_raise(ArgumentError) { load File.expand_path('../../lib/devise/orm/dynamodb.rb', __FILE__) }
        assert_match(/Unknown DynamoDB library :cassandra/, error.message)
      end
    end
  end

  class DynamodbTasksTest < ActiveSupport::TestCase
    test 'models lists the DynamoDB devise models' do
      models = Devise::Orm::Dynamodb::Tasks.models
      assert_includes models, User
      assert_includes models, Admin
    end

    test 'create_tables skips existing tables' do
      io = StringIO.new
      result = Devise::Orm::Dynamodb::Tasks.create_tables([User, Admin], io: io)
      assert_empty result[:created]
      assert_equal [User.table_name.to_s, Admin.table_name.to_s].sort, result[:existing].sort
      assert_match(/already exists/, io.string)
    end

    test 'create_tables creates missing tables' do
      Devise::Orm::Dynamodb::Tasks.stubs(:table_exists?).returns(false)
      Devise::Orm::Dynamodb::Tasks.expects(:create_table).with(User)
      result = Devise::Orm::Dynamodb::Tasks.create_tables([User], io: nil)
      assert_equal [User.table_name.to_s], result[:created]
    end

    test 'lookup_attributes lists the attributes devise queries by' do
      attributes = Devise::Orm::Dynamodb::Tasks.lookup_attributes(User)
      assert_equal [:email, :reset_password_token, :confirmation_token, :unlock_token], attributes
      assert_includes Devise::Orm::Dynamodb::Tasks.lookup_attributes(Admin), :unconfirmed_email
      assert_equal [:email], User.authentication_keys, "must not modify the model configuration"
    end

    test 'check_indexes reports the lookups that need a scan' do
      io = StringIO.new
      report = Devise::Orm::Dynamodb::Tasks.check_indexes([User], io: io)
      assert_not_includes report[User], :email
      assert_includes report[User], :reset_password_token
      assert_match(/will Scan the whole table/, io.string)
    end

    test 'rake tasks are defined' do
      require 'rake'
      Rake::Task.clear
      Rails.application.load_tasks
      %w(devise:dynamodb:create_tables devise:dynamodb:check_indexes).each do |name|
        assert Rake::Task.task_defined?(name)
        assert_equal 1, Rake::Task[name].actions.size, "#{name} must be loaded once"
      end
    end
  end
end
