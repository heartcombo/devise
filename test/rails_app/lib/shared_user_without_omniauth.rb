module SharedUserWithoutOmniauth
  extend ActiveSupport::Concern

  included do
    devise :database_authenticatable, :confirmable, :lockable, :recoverable,
      :registerable, :rememberable, :timeoutable,
      :trackable, :validatable
  end

  def raw_confirmation_token
    @raw_confirmation_token
  end
end
