require 'test/test_helper'
require 'digest/sha1'

class AuthenticatableTest < ActiveSupport::TestCase

  def encrypt_password(user, pepper=User.pepper, stretches=User.stretches, encryptor=::Devise::Encryptors::Sha1)
    encryptor.digest('123456', stretches, user.password_salt, pepper)
  end

  test 'should respond to password and password confirmation' do
    user = new_user
    assert user.respond_to?(:password)
    assert user.respond_to?(:password_confirmation)
  end

  test 'should generate salt while setting password' do
    assert_present new_user.password_salt
    assert_present new_user(:password => nil).password_salt
    assert_present new_user(:password => '').password_salt
    assert_present create_user.password_salt
  end

  test 'should not change password salt when updating' do
    user = create_user
    salt = user.password_salt
    user.expects(:password_salt=).never
    user.save!
    assert_equal salt, user.password_salt
  end

  test 'should generate a base64 hash using SecureRandom for password salt' do
    ActiveSupport::SecureRandom.expects(:base64).with(15).returns('friendly_token')
    assert_equal 'friendly_token', new_user.password_salt
  end

  test 'should never generate the same salt for different users' do
    password_salts = []
    10.times do
      salt = create_user.password_salt
      assert_not password_salts.include?(salt)
      password_salts << salt
    end
  end

  test 'should generate encrypted password while setting password' do
    assert_present new_user.encrypted_password
    assert_present new_user(:password => nil).encrypted_password
    assert_present new_user(:password => '').encrypted_password
    assert_present create_user.encrypted_password
  end

  test 'should encrypt password again if password has changed' do
    user = create_user
    encrypted_password = user.encrypted_password
    user.password = user.password_confirmation = 'new_password'
    user.save!
    assert_not_equal encrypted_password, user.encrypted_password
  end

  test 'should fallback to Sha1 as default encryption' do
    user = new_user
    assert_equal encrypt_password(user), user.encrypted_password
  end

  test 'should fallback to devise pepper default configuring' do
    begin
      Devise.pepper = ''
      user = new_user
      assert_equal encrypt_password(user), user.encrypted_password
      assert_not_equal encrypt_password(user, 'another_pepper'), user.encrypted_password
      Devise.pepper = 'new_pepper'
      user = new_user
      assert_equal encrypt_password(user, 'new_pepper'), user.encrypted_password
      assert_not_equal encrypt_password(user, 'another_pepper'), user.encrypted_password
      Devise.pepper = '123456'
      user = new_user
      assert_equal encrypt_password(user, '123456'), user.encrypted_password
      assert_not_equal encrypt_password(user, 'another_pepper'), user.encrypted_password
    ensure
      Devise.pepper = nil
    end
  end

  test 'should fallback to devise stretches default configuring' do
    swap Devise, :stretches => 1 do
      user = new_user
      assert_equal encrypt_password(user, nil, 1), user.encrypted_password
      assert_not_equal encrypt_password(user, nil, 2), user.encrypted_password
    end
  end

  test 'should respect encryptor configuration' do
    User.instance_variable_set(:@encryptor_class, nil)

    swap Devise, :encryptor => :sha512 do
      begin
        user = create_user
        assert_equal user.encrypted_password, encrypt_password(user, User.pepper, User.stretches, ::Devise::Encryptors::Sha512)
      ensure
        User.instance_variable_set(:@encryptor_class, nil)
      end
    end
  end

  test 'should test for a valid password' do
    user = create_user
    assert user.valid_password?('123456')
    assert_not user.valid_password?('654321')
  end

  test 'should authenticate a valid user with email and password and return it' do
    user = create_user
    User.any_instance.stubs(:confirmed?).returns(true)
    authenticated_user = User.authenticate(:email => user.email, :password => user.password)
    assert_equal authenticated_user, user
  end

  test 'should return nil when authenticating an invalid user by email' do
    user = create_user
    authenticated_user = User.authenticate(:email => 'another.email@email.com', :password => user.password)
    assert_nil authenticated_user
  end

  test 'should return nil when authenticating an invalid user by password' do
    user = create_user
    authenticated_user = User.authenticate(:email => user.email, :password => 'another_password')
    assert_nil authenticated_user
  end

  test 'should use authentication keys to retrieve users' do
    swap Devise, :authentication_keys => [:username] do
      user = create_user(:username => "josevalim")
      assert_nil User.authenticate(:email => user.email, :password => user.password)
      assert_not_nil User.authenticate(:username => user.username, :password => user.password)
    end
  end

  test 'should allow overwriting find for authentication conditions' do
    admin = Admin.create!(valid_attributes)
    assert_not_nil Admin.authenticate(:email => admin.email, :password => admin.password)
  end

  test 'should never authenticate an account' do
    account = Account.create!(valid_attributes)
    assert_nil Account.authenticate(:email => account.email, :password => account.password)
  end

  test 'should serialize user into session' do
    user = create_user
    assert_equal [User, user.id], User.serialize_into_session(user)
  end

  test 'should serialize user from session' do
    user = create_user
    assert_equal user.id, User.serialize_from_session([User, user.id]).id
  end

  test 'should not serialize another klass from session' do
    user = create_user
    assert_raise RuntimeError, /ancestors/ do
      User.serialize_from_session([Admin, user.id])
    end
  end

  test 'should serialize another klass from session' do
    user = create_user
    klass = Class.new(User)
    assert_equal user.id, User.serialize_from_session([klass, user.id]).id
  end
end
