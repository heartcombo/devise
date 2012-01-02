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
    klass = record.class
    array = klass.serialize_into_session(record)
    array.unshift(klass.name)
  end

  def deserialize(keys)
    klass, *args = keys

    begin
      ActiveSupport::Inflector.constantize(klass).serialize_from_session(*args)
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