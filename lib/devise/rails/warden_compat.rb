module Warden::Mixins::Common
  def request
    @request ||= ActionDispatch::Request.new(env)
  end

  # This is called internally by Warden on logout
  def reset_session!
    request.reset_session
  end

  def cookies
    request.cookie_jar
  end
end

class Warden::SessionSerializer
  def serialize(record)
    [record.class.name, record.to_key, record.authenticatable_salt]
  end

  def deserialize(keys)
    if keys.size == 2
      raise "Devise changed how it stores objects in session. If you are seeing this message, " <<
        "you can fix it by changing one character in your cookie secret or cleaning up your " <<
        "database sessions if you are using a db store."
    end

    klass, id, salt = keys

    begin
      record = klass.constantize.to_adapter.get(id)
      record if record && record.authenticatable_salt == salt
    rescue NameError => e
      if e.message =~ /uninitialized constant/
        Rails.logger.debug "[Devise] Trying to deserialize invalid class #{klass}"
        nil
      else
        raise
      end
    end
  end
end

unless Devise.rack_session?
  class ActionDispatch::Request
    def reset_session
      session.destroy if session && session.respond_to?(:destroy)
      self.session = {}
      @env['action_dispatch.request.flash_hash'] = nil
    end
  end

  Warden::Manager.after_set_user :event => [:set_user, :authentication] do |record, warden, options|
    if options[:scope] && warden.authenticated?(options[:scope])
      request, flash = warden.request, warden.env['action_dispatch.request.flash_hash']
      backup = request.session.to_hash
      backup.delete("session_id")
      request.reset_session
      warden.env['action_dispatch.request.flash_hash'] = flash
      request.session.update(backup)
    end
  end
end