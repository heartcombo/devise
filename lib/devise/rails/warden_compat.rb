module Warden::Mixins::Common
  def request
    @request ||= ActionDispatch::Request.new(env)
  end

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
