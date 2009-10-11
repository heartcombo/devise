class ActionController::IntegrationTest

  def warden
    request.env['warden']
  end

  def create_user(options={})
    @user ||= begin
      user = User.create!(
        :email => 'user@test.com', :password => '123456', :password_confirmation => '123456'
      )
      user.confirm! unless options[:confirm] == false
      user
    end
  end

  def create_admin(options={})
    @admin ||= begin
      admin = Admin.create!(
        :email => 'admin@test.com', :password => '123456', :password_confirmation => '123456'
      )
      admin.confirm! unless options[:confirm] == false
      admin
    end
  end

  def sign_in_as_user(options={}, &block)
    create_user(options)
    visit new_user_session_path
    fill_in 'email', :with => 'user@test.com'
    fill_in 'password', :with => '123456'
    yield if block_given?
    click_button 'Sign In'
  end

  def sign_in_as_admin(options={}, &block)
    create_admin(options)
    visit new_admin_session_path
    fill_in 'email', :with => 'admin@test.com'
    fill_in 'password', :with => '123456'
    yield if block_given?
    click_button 'Sign In'
  end
end
