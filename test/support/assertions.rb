require 'active_support/test_case'

class ActiveSupport::TestCase
  def assert_not(assertion)
    assert !assertion
  end

  def assert_blank(assertion)
    assert assertion.blank?
  end

  def assert_not_blank(assertion)
    assert !assertion.blank?
  end
  alias :assert_present :assert_not_blank

  def assert_email_sent(address = nil, &block)
    assert_difference('ActionMailer::Base.deliveries.size') { yield }
    if address.present?
      assert_equal address, ActionMailer::Base.deliveries.last['to'].to_s
    end
  end

  def assert_email_not_sent(&block)
    assert_no_difference('ActionMailer::Base.deliveries.size') { yield }
  end

  def assert_same_content(result, expected)
    assert expected.size == result.size, "the arrays doesn't have the same size"
    expected.each do |element|
      assert result.include?(element), "The array doesn't include '#{element}'."
    end
  end

  def assert_raise_with_message(exception_klass, message)
    exception = assert_raise exception_klass do
      yield
    end

    assert_equal exception.message, message, "The expected message was #{message} but your exception throwed #{exception.message}"
  end
end
