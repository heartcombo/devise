module Devise
  module Models
    # This module redefine to_xml and serializable_hash in models for more
    # secure defaults. By default, it removes from the serializable model
    # all attributes that are *not* accessible. You can remove this default
    # by using :force_except and passing a new list of attributes you want
    # to exempt. All attributes given to :except will simply add names to
    # exempt to Devise internal list.
    module Serializable
      extend ActiveSupport::Concern

      array = %w(serializable_hash)
      # to_xml does not call serializable_hash on 3.1
      array << "to_xml" if Rails::VERSION::STRING[0,3] == "3.1"

      array.each do |method|
        class_eval <<-RUBY, __FILE__, __LINE__
          def #{method}(options=nil)
            options ||= {}
            if options.key?(:force_except)
              options[:except] = options.delete(:force_except)
              super(options)
            elsif self.class.blacklist_keys?
              except = Array(options[:except])
              super(options.merge(:except => except + self.class.blacklist_keys))
            else
              super
            end
          end
        RUBY
      end

      module ClassMethods
        # Return true if we can retrieve blacklist keys from the record.
        def blacklist_keys?
          @has_except_keys ||= respond_to?(:accessible_attributes) && !accessible_attributes.to_a.empty?
        end

        # Returns keys that should be removed when serializing the record.
        def blacklist_keys
          @blacklist_keys ||= to_adapter.column_names.map(&:to_s) - accessible_attributes.to_a.map(&:to_s)
        end
      end
    end
  end
end