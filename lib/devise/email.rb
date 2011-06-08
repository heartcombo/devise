# This e-mail validation regexes were retrieved from SixArm Ruby
# e-mail validation gem (https://github.com/SixArm/sixarm_ruby_email_address_validation)
# As said on https://github.com/SixArm/sixarm_ruby_email_address_validation/blob/master/LICENSE.txt,
# we added it using Ruby license terms.

module Devise
  module Email
    QTEXT           = Regexp.new '[^\\x0d\\x22\\x5c\\x80-\\xff]', nil, 'n'
    DTEXT           = Regexp.new '[^\\x0d\\x5b-\\x5d\\x80-\\xff]', nil, 'n'
    ATOM            = Regexp.new '[^\\x00-\\x20\\x22\\x28\\x29\\x2c\\x2e\\x3a-\\x3c\\x3e\\x40\\x5b-\\x5d\\x7f-\\xff]+', nil, 'n'
    QUOTED_PAIR     = Regexp.new '\\x5c[\\x00-\\x7f]', nil, 'n'
    DOMAIN_LITERAL  = Regexp.new "\\x5b(?:#{DTEXT}|#{QUOTED_PAIR})*\\x5d", nil, 'n'
    QUOTED_STRING   = Regexp.new "\\x22(?:#{QTEXT}|#{QUOTED_PAIR})*\\x22", nil, 'n'
    DOMAIN_REF      = ATOM
    SUB_DOMAIN      = "(?:#{DOMAIN_REF}|#{DOMAIN_LITERAL})"
    WORD            = "(?:#{ATOM}|#{QUOTED_STRING})"
    DOMAIN          = "#{SUB_DOMAIN}(?:\\x2e#{SUB_DOMAIN})*"
    LOCAL_PART      = "#{WORD}(?:\\x2e#{WORD})*"
    SPEC            = "#{LOCAL_PART}\\x40#{DOMAIN}"
    PATTERN         = Regexp.new "#{SPEC}", nil, 'n'
    EXACT_PATTERN   = Regexp.new "\\A#{SPEC}\\z", nil, 'n'
  end
end