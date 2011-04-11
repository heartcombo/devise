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
        "you can fix it by changing one character in your secret_token or cleaning up your " <<
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
  # We cannot use Rails Indifferent Hash because it messes up the flash object.
  class Devise::IndifferentHash < Hash
    alias_method :regular_writer, :[]= unless method_defined?(:regular_writer)
    alias_method :regular_update, :update unless method_defined?(:regular_update)

    def [](key)
      super(convert_key(key))
    end

    def []=(key, value)
      regular_writer(convert_key(key), value)
    end

    alias_method :store, :[]=

    def update(other_hash)
      other_hash.each_pair { |key, value| regular_writer(convert_key(key), value) }
      self
    end

    alias_method :merge!, :update

    def key?(key)
      super(convert_key(key))
    end

    alias_method :include?, :key?
    alias_method :has_key?, :key?
    alias_method :member?, :key?

    def fetch(key, *extras)
      super(convert_key(key), *extras)
    end

    def values_at(*indices)
      indices.collect {|key| self[convert_key(key)]}
    end

    def merge(hash)
      self.dup.update(hash)
    end

    def delete(key)
      super(convert_key(key))
    end

    def stringify_keys!; self end
    def stringify_keys; dup end

    undef :symbolize_keys!
    def symbolize_keys; to_hash.symbolize_keys end

    def to_options!; self end
    def to_hash; Hash.new.update(self) end

    protected

    def convert_key(key)
      key.kind_of?(Symbol) ? key.to_s : key
    end
  end

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
      request.session = Devise::IndifferentHash.new.update(backup)
    end
  end
end