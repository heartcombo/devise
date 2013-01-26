module Devise
  class ParamFilter
    def initialize(case_insensitive_keys, strip_whitespace_keys)
      @case_insensitive_keys = case_insensitive_keys || []
      @strip_whitespace_keys = strip_whitespace_keys || []
    end

    def filter(conditions)
      conditions = stringify_params(conditions.dup)

      @case_insensitive_keys.each do |k|
        value = conditions[k]
        next unless value.respond_to?(:downcase)
        conditions[k] = value.downcase
      end

      @strip_whitespace_keys.each do |k|
        value = conditions[k]
        next unless value.respond_to?(:strip)
        conditions[k] = value.strip
      end

      conditions
    end

    # Force keys to be string to avoid injection on mongoid related database.
    def stringify_params(conditions)
      return conditions unless conditions.is_a?(Hash)
      conditions.each do |k, v|
        conditions[k] = v.to_s if param_requires_string_conversion?(v)
      end
    end

    private

    def param_requires_string_conversion?(value)
      true
    end
  end
end
