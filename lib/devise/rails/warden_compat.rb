module Warden::Mixins::Common
  def request
    @request ||= env['action_controller.rescue.request']
  end

  def reset_session!
    raw_session.inspect # why do I have to inspect it to get it to clear?
    raw_session.clear
  end

  def response
    @response ||= env['action_controller.rescue.response']
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