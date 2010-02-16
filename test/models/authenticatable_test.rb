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

  test 'should generate encrypted password and salt while setting password' do
    user = new_user
    assert_present user.password_salt
    assert_present user.encrypted_password
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

  test 'should not generate salt if password is blank' do
    assert_blank new_user(:password => nil).password_salt
    assert_blank new_user(:password => '').password_salt
  end

  test 'should not generate encrypted password if password is blank' do
    assert_blank new_user(:password => nil).encrypted_password
    assert_blank new_user(:password => '').encrypted_password
  end

  test 'should encrypt password again if password has changed' do
    user = create_user
    encrypted_password = user.encrypted_password
    user.password = user.password_confirmation = 'new_password'
    user.save!
    assert_not_equal encrypted_password, user.encrypted_password
  end

  test 'should fallback to sha1 as default encryption' do
    user = new_user
    assert_equal encrypt_password(user), user.encrypted_password
  end

  test 'should fallback to devise pepper default configuration' do
    begin
      Devise.pepper = ''
      user = new_user
      assert_equal encrypt_password(user), user.encrypted_password
      assert_not_equal encrypt_password(user, 'another_pepper'), user.encrypted_password

      Devise.pepper = 'new_pepper'
      user = new_user
      assert_equal encrypt_password(user, 'new_pepper'), user.encrypted_password
      assert_not_equal encrypt_password(user, 'another_pepper'), user.encrypted_password
    ensure
      Devise.pepper = nil
    end
  end

  test 'should fallback to devise stretches default configuration' do
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
    user.confirm!
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
      user = create_user
      assert_nil User.authenticate(:email => user.email, :password => user.password)
      assert_not_nil User.authenticate(:username => user.username, :password => user.password)
    end
  end

  test 'should allow overwriting find for authentication conditions' do
    admin = Admin.create!(valid_attributes)
    assert_not_nil Admin.authenticate(:email => admin.email, :password => admin.password)
  end

  test 'should respond to current password' do
    assert new_user.respond_to?(:current_password)
  end

  test 'should update password with valid current password' do
    user = create_user
    assert user.update_with_password(:current_password => '123456',
      :password => 'pass321', :password_confirmation => 'pass321')
    assert user.reload.valid_password?('pass321')
  end

  test 'should add an error to current password when it is invalid' do
    user = create_user
    assert_not user.update_with_password(:current_password => 'other',
      :password => 'pass321', :password_confirmation => 'pass321')
    assert user.reload.valid_password?('123456')
    assert_match "is invalid", user.errors[:current_password].join
  end

  test 'should add an error to current password when it is blank' do
    user = create_user
    assert_not user.update_with_password(:password => 'pass321',
      :password_confirmation => 'pass321')
    assert user.reload.valid_password?('123456')
    assert_match "can't be blank", user.errors[:current_password].join
  end

  test 'should ignore password and its confirmation if they are blank' do
    user = create_user
    assert user.update_with_password(:current_password => '123456', :email => "new@email.com")
    assert_equal "new@email.com", user.email
  end

  test 'should not update password with invalid confirmation' do
    user = create_user
    assert_not user.update_with_password(:current_password => '123456',
      :password => 'pass321', :password_confirmation => 'other')
    assert user.reload.valid_password?('123456')
  end

  test 'should clean up password fields on failure' do
    user = create_user
    assert_not user.update_with_password(:current_password => '123456',
      :password => 'pass321', :password_confirmation => 'other')
    assert user.password.blank?
    assert user.password_confirmation.blank?
  end
end
