module Devise
  module Views
    module Helpers
      def self.define_helpers(mapping)
        mapping = mapping.name
        class_eval <<-METHODS, __FILE__, __LINE__ + 1
          def signed_in_#{mapping}_content(&block)
            block.call if #{mapping}_signed_in?
          end

          def signed_out_mapping_content(&block)
            block.call if #{mapping}_signed_out?
          end
        METHODS
      end
    end
  end
end
