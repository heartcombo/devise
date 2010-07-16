module SharedUser
  extend ActiveSupport::Concern

  included do
    devise :database_authenticatable, :confirmable, :lockable, :recoverable,
           :registerable, :rememberable, :timeoutable, :token_authenticatable,
           :trackable, :validatable, :oauthable, :oauth_providers => [:github, :facebook]

    # They need to be included after Devise is called.
    extend ExtendMethods
  end

  module ExtendMethods
    def find_for_facebook_oauth(access_token, signed_in_resource=nil)
      User.create { |u| u.update_with_facebook_oauth(access_token) }
    end

    def new_with_session(params, session)
      super.tap do |user|
        if session[:user_facebook_oauth_token]
          access_token = oauth_access_token(:facebook, session[:user_facebook_oauth_token])
          user.update_with_facebook_oauth(access_token)
        end
      end
    end
  end

  def update_with_facebook_oauth(access_token)
    data = ActiveSupport::JSON.decode(access_token.get('/me'))

    self.username = data["username"] unless username.present?
    self.email    = data["email"] unless email.present?
    self.confirmed_at ||= Time.now

    unless password.present?
      self.password = Devise.friendly_token
      self.password_confirmation = nil
    end

    yield self if block_given?    
  end
end
