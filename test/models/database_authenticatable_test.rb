require 'test_helper'
require 'digest/sha1'

class DatabaseAuthenticatableTest < ActiveSupport::TestCase

  def encrypt_password(user, pepper=User.pepper, stretches=User.stretches, encryptor=User.encryptor_class)
    encryptor.digest('123456', stretches, user.password_salt, pepper)
  end

  def swap_with_encryptor(klass, encryptor, options={})
    klass.instance_variable_set(:@encryptor_class, nil)

    swap klass, options.merge(:encryptor => encryptor) do
      begin
        yield
      ensure
        klass.instance_variable_set(:@encryptor_class, nil)
      end
    end
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
    swap_with_encryptor User, :sha1 do
      ActiveSupport::SecureRandom.expects(:base64).with(15).returns('friendly_token')
      assert_equal 'friendly_token', new_user.password_salt
    end
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

  test 'should respect encryptor configuration' do
    swap_with_encryptor User, :sha512 do
      user = create_user
      assert_equal user.encrypted_password, encrypt_password(user, User.pepper, User.stretches, ::Devise::Encryptors::Sha512)
    end
  end

  test 'should test for a valid password' do
    user = create_user
    assert user.valid_password?('123456')
    assert_not user.valid_password?('654321')
  end

  test 'should not validate password when salt is nil' do
    admin = create_admin
    admin.password_salt = nil
    admin.save
    assert_not admin.valid_password?('123456')
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
