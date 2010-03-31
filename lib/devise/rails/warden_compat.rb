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
    [record.class, record.id]
  end

  def deserialize(keys)
    klass, id = keys
    klass.find(:first, :conditions => { :id => id })
  end
end