# frozen_string_literal: true

require 'test_helper'
require 'bcrypt'

class EncryptorTest < ActiveSupport::TestCase
  test 'digest/compare passwords' do
    hashed_password = Devise::Encryptor.digest(Devise, 'example')
    assert Devise::Encryptor.compare(Devise, hashed_password, 'example')
    assert_not Devise::Encryptor.compare(Devise, hashed_password, 'example1')
  end

  test 'false for incorrect bcrypt string' do
    assert_not Devise::Encryptor.compare(Devise, 'incorrect_bcrypt_string', 'example')
  end

  test 'digest/compare support passwords longer 72 bytes' do
    hashed_password = Devise::Encryptor.digest(Devise, 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa123')
    assert Devise::Encryptor.compare(Devise, hashed_password, 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa123')
    assert_not Devise::Encryptor.compare(Devise, hashed_password, 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa125')
  end

  test 'digest/compare support old bcrypt only passwords' do
    password = 'example'
    password_with_pepper = "#{password}#{Devise.pepper}"
    old_hashed_password = ::BCrypt::Password.create(password_with_pepper, cost: Devise.stretches)

    assert Devise::Encryptor.compare(Devise, old_hashed_password, password)
    assert_not Devise::Encryptor.compare(Devise, old_hashed_password, 'examplo')
  end
end
