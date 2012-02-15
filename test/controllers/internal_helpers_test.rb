require 'test_helper'

class MyController < DeviseController
end

class HelpersTest < ActionController::TestCase
  tests MyController

  def setup
    @mock_warden = OpenStruct.new
    @controller.request.env['warden'] = @mock_warden
    @controller.request.env['devise.mapping'] = Devise.mappings[:user]
  end

  test 'get resource name from env' do
    assert_equal :user, @controller.resource_name
  end

  test 'get resource class from env' do
    assert_equal User, @controller.resource_class
  end

  test 'get resource instance variable from env' do
    @controller.instance_variable_set(:@user, user = User.new)
    assert_equal user, @controller.resource
  end

  test 'set resource instance variable from env' do
    user = @controller.send(:resource_class).new
    @controller.send(:resource=, user)

    assert_equal user, @controller.send(:resource)
    assert_equal user, @controller.instance_variable_get(:@user)
  end

  test 'resources methods are not controller actions' do
    assert @controller.class.action_methods.empty?
  end

  test 'require no authentication tests current mapping' do
    @mock_warden.expects(:authenticate?).with(:rememberable, :token_authenticatable, :scope => :user).returns(true)
    @mock_warden.expects(:user).with(:user).returns(User.new)
    @controller.expects(:redirect_to).with(root_path)
    @controller.send :require_no_authentication
  end

  test 'require no authentication only checks if already authenticated if no inputs strategies are available' do
    Devise.mappings[:user].expects(:no_input_strategies).returns([])
    @mock_warden.expects(:authenticate?).never
    @mock_warden.expects(:authenticated?).with(:user).once.returns(true)
    @mock_warden.expects(:user).with(:user).returns(User.new)
    @controller.expects(:redirect_to).with(root_path)
    @controller.send :require_no_authentication
  end

  test 'require no authentication sets a flash message' do
    @mock_warden.expects(:authenticate?).with(:rememberable, :token_authenticatable, :scope => :user).returns(true)
    @mock_warden.expects(:user).with(:user).returns(User.new)
    @controller.expects(:redirect_to).with(root_path)
    @controller.send :require_no_authentication
    assert flash[:alert] == I18n.t("devise.failure.already_authenticated")
  end

  test 'signed in resource returns signed in resource for current scope' do
    @mock_warden.expects(:authenticate).with(:scope => :user).returns(User.new)
    assert_kind_of User, @controller.signed_in_resource
  end

  test 'is a devise controller' do
    assert @controller.devise_controller?
  end

  test 'does not issue blank flash messages' do
    I18n.stubs(:t).returns('   ')
    @controller.send :set_flash_message, :notice, :send_instructions
    assert flash[:notice].nil?
  end

  test 'issues non-blank flash messages normally' do
    I18n.stubs(:t).returns('non-blank')
    @controller.send :set_flash_message, :notice, :send_instructions
    assert_equal 'non-blank', flash[:notice]
  end

  test 'uses custom i18n options' do
    @controller.stubs(:devise_i18n_options).returns(:default => "devise custom options")
    @controller.send :set_flash_message, :notice, :invalid_i18n_messagesend_instructions
    assert_equal 'devise custom options', flash[:notice]
  end

  test 'navigational_formats not returning a wild card' do
    MyController.send(:public, :navigational_formats)
    Devise.navigational_formats = [:"*/*", :html]
    assert_not @controller.navigational_formats.include?(:"*/*")
    MyController.send(:protected, :navigational_formats)
  end
end
