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