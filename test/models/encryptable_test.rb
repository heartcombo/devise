require 'test_helper'

class EncryptableTest < ActiveSupport::TestCase
  def encrypt_password(admin, pepper=Admin.pepper, stretches=Admin.stretches, encryptor=Admin.encryptor_class)
    encryptor.digest('123456', stretches, admin.password_salt, pepper)
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

  test 'should generate salt while setting password' do
    assert_present create_admin.password_salt
  end

  test 'should not change password salt when updating' do
    admin = create_admin
    salt = admin.password_salt
    admin.expects(:password_salt=).never
    admin.save!
    assert_equal salt, admin.password_salt
  end

  test 'should generate a base64 hash using SecureRandom for password salt' do
    swap_with_encryptor Admin, :sha1 do
      SecureRandom.expects(:base64).with(15).returns('friendly_token')
      assert_equal 'friendly_token', create_admin.password_salt
    end
  end

  test 'should not generate salt if password is blank' do
    assert_blank create_admin(:password => nil).password_salt
    assert_blank create_admin(:password => '').password_salt
  end

  test 'should encrypt password again if password has changed' do
    admin = create_admin
    encrypted_password = admin.encrypted_password
    admin.password = admin.password_confirmation = 'new_password'
    admin.save!
    assert_not_equal encrypted_password, admin.encrypted_password
  end

  test 'should respect encryptor configuration' do
    swap_with_encryptor Admin, :sha512 do
      admin = create_admin
      assert_equal admin.encrypted_password, encrypt_password(admin, Admin.pepper, Admin.stretches, ::Devise::Encryptors::Sha512)
    end
  end

  test 'should not validate password when salt is nil' do
    admin = create_admin
    admin.password_salt = nil
    admin.save
    assert_not admin.valid_password?('123456')
  end
end
