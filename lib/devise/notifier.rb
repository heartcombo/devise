module Devise
  class Notifier < ::ActionMailer::Base
    self.view_paths.unshift(File.join(File.dirname(__FILE__), '..', '..', 'views'))

    def confirmation_instructions(record)
      #
    end
  end
end

