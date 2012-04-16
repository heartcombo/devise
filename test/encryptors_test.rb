require 'test_helper'

class Encryptors < ActiveSupport::TestCase
  test 'should match a password created by scrypt' do
    secret    = '400$8$5$edf9769b2f75b26abfb539d649a5bbe2279b51da$1eb4af5f494573214e57f0521bf7c4d5c80fb793'
    pepper    = 'd90e854a76a208eeb7122c11b073d74597afdf78b0bf8eef2dce59652dcda61537963ec319bd1dcf30d6db3ac65c7efbbd4dd82d9b7a4cde2839ced708e03b37'
    salt      = '400$8$5$14a79bbc91b70a1fd5b5c02e75c14bd8e7f84d57'
    encryptor = Devise::Encryptors::SCrypt.digest('123mudar', nil, salt, pepper)
  end

  test 'should match a password created by authlogic' do
    authlogic = "b623c3bc9c775b0eb8edb218a382453396fec4146422853e66ecc4b6bc32d7162ee42074dcb5f180a770dc38b5df15812f09bbf497a4a1b95fe5e7d2b8eb7eb4"
    encryptor = Devise::Encryptors::AuthlogicSha512.digest('123mudar', 20, 'usZK_z_EAaF61Gwkw-ed', '')
    assert_equal authlogic, encryptor
  end

  test 'should match a password created by restful_authentication' do
    restful_authentication = "93110f71309ce91366375ea44e2a6f5cc73fa8d4"
    encryptor = Devise::Encryptors::RestfulAuthenticationSha1.digest('123mudar', 10, '48901d2b247a54088acb7f8ea3e695e50fe6791b', 'fee9a51ec0a28d11be380ca6dee6b4b760c1a3bf')
    assert_equal restful_authentication, encryptor
  end

  test 'should match a password created by clearance' do
    clearance = "0f40bbae18ddefd7066276c3ef209d40729b0378"
    encryptor = Devise::Encryptors::ClearanceSha1.digest('123mudar', nil, '65c58472c207c829f28c68619d3e3aefed18ab3f', nil)
    assert_equal clearance, encryptor
  end

  Devise::ENCRYPTORS_LENGTH.each do |key, value|
    test "should have length #{value} for #{key.inspect}" do
      swap Devise, :encryptor => key do
        encryptor = Devise::Encryptors.const_get(key.to_s.classify)
        assert_equal value, encryptor.digest('a', 4, encryptor.salt(4), nil).size
      end
    end
  end
end
