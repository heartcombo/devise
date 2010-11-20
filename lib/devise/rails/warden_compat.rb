module Warden::Mixins::Common
  def request
    @request ||= ActionDispatch::Request.new(env)
  end

  def reset_session!
    raw_session.inspect # why do I have to inspect it to get it to clear?
    raw_session.clear
  end

  def cookies
    request.cookie_jar
  end
end

class Warden::SessionSerializer
  def serialize(record)
    [record.class.name, record.id]
  end

  def deserialize(keys)
    klass, id = keys

    if klass.is_a?(Class)
      raise "Devise changed how it stores objects in session. If you are seeing this message, " <<
        "you can fix it by changing one character in your cookie secret, forcing all previous " <<
        "cookies to expire, or cleaning up your database sessions if you are using a db store."
    end

    klass.constantize.find(:first, :conditions => { :id => id })
  rescue NameError => e
    if e.message =~ /uninitialized constant/
      Rails.logger.debug "Trying to deserialize invalid class #{klass}"
      nil
    else
      raise
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