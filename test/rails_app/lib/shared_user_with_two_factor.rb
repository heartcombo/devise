# frozen_string_literal: true

module SharedUserWithTwoFactor
  extend ActiveSupport::Concern

  included do
    devise :database_authenticatable, :registerable, :recoverable,
           :two_factor_authenticatable, two_factor_methods: [:test_otp]

    validates_uniqueness_of :email, allow_blank: true, if: :devise_will_save_change_to_email?
  end
end
