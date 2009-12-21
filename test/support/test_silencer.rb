module Devise
  module TestSilencer
    def test(*args, &block); end
  end
end