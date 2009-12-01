module Devise
  module Encryptors
    autoload :AuthlogicSha512, 'devise/encryptors/authlogic_sha512' 
    autoload :AuthlogicSha1, 'devise/encryptors/authlogic_sha1' 
    autoload :RestfulAuthenticationSha1, 'devise/encryptors/restful_authentication_sha1' 
    autoload :Sha512, 'devise/encryptors/sha512' 
    autoload :Sha1, 'devise/encryptors/sha1' 
  end
end