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
    klass_name, *args = keys

    begin
      klass = ActiveSupport::Inflector.constantize(klass_name)
      if klass.respond_to? :serialize_from_session
        klass.serialize_from_session(*args)
      else
        Rails.logger.warn "[Devise] Stored serialized class #{klass_name} seems not to be Devise enabled anymore. Did you do that on purpose?"
        nil
      end
    rescue NameError => e
      if e.message =~ /uninitialized constant/
        Rails.logger.debug "[Devise] Trying to deserialize invalid class #{klass_name}"
        nil
      else
        raise
      end
    end
  end
end
