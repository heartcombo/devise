# frozen_string_literal: true

require 'devise/orm/dynamodb/model'

module Devise
  module Orm
    module Dynamodb
      # Model integration for Dynamoid (https://github.com/Dynamoid/dynamoid).
      #
      # Dynamoid already provides most of what Devise needs: ActiveModel
      # validations and callbacks, and an ActiveModel-like dirty API. This
      # module fills in the remaining gaps.
      module DynamoidModel
        extend ActiveSupport::Concern

        include Devise::Orm::Dynamodb::Model

        included do
          # Devise callbacks such as the email/password changed notifications
          # (after_update) need to know what was persisted by the *current*
          # save, which ActiveRecord exposes as `saved_changes`. Dynamoid only
          # promotes pending changes to `previous_changes` once all callbacks
          # have run, so we flag when we're inside a save: while the flag is
          # set, the pending changes (which already include any before_*
          # callback modifications) *are* the saved changes.
          #
          # `prepend: true` guarantees it wraps the devise callbacks
          # regardless of the order they are declared in.
          set_callback :save, :around, :devise_track_saving, prepend: true
        end

        module ClassMethods
          def devise_atomic_increment(counter_name, id, by)
            inc(id, counter_name => by)
          end
        end

        # Dynamoid's +update+ takes a block of low level DynamoDB update
        # operations. Devise (and Rails controllers in general) call
        # +update(attributes)+ expecting ActiveRecord semantics: assign the
        # attributes, validate and save. Both behaviours are kept.
        def update(attributes = nil, &block)
          return super if block

          assign_attributes(attributes || {})
          save
        end

        # Same as +update+, but raising when the record is invalid.
        def update!(attributes = nil, &block)
          return super if block

          assign_attributes(attributes || {})
          save!
        end

        # Dynamoid's +attributes+ omits fields that were never set (nil), so
        # serialize every declared field, like ActiveRecord does with columns.
        def attribute_names_for_serialization
          self.class.attributes.keys.map(&:to_s)
        end

        private

        def devise_pending_changes
          changes
        end

        def devise_previous_changes
          previous_changes
        end
      end
    end
  end
end
