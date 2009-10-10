class ActionController::IntegrationTest

  def warden
    request.env['warden']
  end

  def create_user(options={})
    @user ||= begin
      user = User.create!(
        :email => 'test@test.com', :password => '123456', :password_confirmation => '123456'
      )
      user.confirm! unless options[:confirm] == false
      user
    end
  end

  def sign_in(options={}, &block)
    create_user(options)
    visit 'users/session/new'
    fill_in 'email', :with => 'test@test.com'
    fill_in 'password', :with => '123456'
    yield if block_given?
    click_button 'Sign In'
  end
end
