module Devise
  class Notifier < ::ActionMailer::Base

    def confirmation_instructions(record)
      # TODO: configure email
    end

    def reset_password_instructions(record)
      # TODO
    end
  end
end

Devise::Notifier.template_root = File.join(File.dirname(__FILE__), '..', 'views')

