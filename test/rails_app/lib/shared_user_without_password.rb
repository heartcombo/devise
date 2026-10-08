# frozen_string_literal: true

module SharedUserWithoutPassword
  extend ActiveSupport::Concern

  included do
    # NOTE: This is missing :database_authenticatable to avoid defining a `password` method.
    # It is also missing :omniauthable because that adds unnecessary complexity to the setup
    devise :confirmable, :lockable, :recoverable,
           :registerable, :rememberable, :timeoutable,
           :trackable, :validatable,
           reconfirmable: false

  end
end
