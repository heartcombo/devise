module Devise
  class ParamFilter
    def initialize(case_insensitive_keys, strip_whitespace_keys)
      @case_insensitive_keys = case_insensitive_keys || []
      @strip_whitespace_keys = strip_whitespace_keys || []
    end

    def filter(conditions)
      conditions = stringify_params(conditions.dup)

      apply_filter_method_to_condition_keys(conditions, :downcase, @case_insensitive_keys)
      apply_filter_method_to_condition_keys(conditions, :strip, @strip_whitespace_keys)

      conditions
    end

    def apply_filter_method_to_condition_keys(conditions, method, condition_keys)
      condition_keys.each do |k|
        value = conditions[k]
        conditions[k] = value.send(method) if value.respond_to?(method)
      end
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
