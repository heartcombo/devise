module Devise
  module Views
    module Helpers

      # Generates helpers that do something based on mappings authentication status,
      # thereby avoiding the use of repetitive if/else blocks
      #
      # Generated Methods => signed_in_user & signed_out_user
      #
      # signed_in_user do
      #    <h1>Hello <%= @user.name %> </h1>
      # end
      #
      # signed_out_user do
      #   <%= link_to "Sign In", new_user_session_path %>
      # end
      #
      # These methods can also be used at the controller level:
      #
      # def some_action
      #   signed_in_user {render @users}
      #   signed_out_user {redirect_to root_path}
      # end

      def self.define_helpers(mapping)
        mapping = mapping.name
        class_eval <<-METHODS, __FILE__, __LINE__ + 1
          def signed_in_#{mapping}(&block)
            block.call if #{mapping}_signed_in?
          end

          def signed_out_#{mapping}(&block)
            block.call unlesss #{mapping}_signed_in?
          end
        METHODS
      end
    end
  end
end
