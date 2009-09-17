require 'test_helper'

class NotifierTest < ActiveSupport::TestCase

  def setup
    ActionMailer::Base.deliveries = []
  end

  # TODO
end

