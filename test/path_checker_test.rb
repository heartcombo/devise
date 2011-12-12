require 'test_helper'

class PathCheckerTest < ActiveSupport::TestCase
  test 'check if sign out path matches' do
    path_checker = Devise::PathChecker.new({"PATH_INFO" => "/users/sign_out"}, :user)
    assert path_checker.signing_out?

    path_checker = Devise::PathChecker.new({"PATH_INFO" => "/users/sign_in"}, :user)
    assert_not path_checker.signing_out?
  end

  test 'considers script name' do
    path_checker = Devise::PathChecker.new({"SCRIPT_NAME" => "/users", "PATH_INFO" => "/sign_out"}, :user)
    assert path_checker.signing_out?
  end

  test 'ignores invalid routes' do
    path_checker = Devise::PathChecker.new({"PATH_INFO" => "/users/sign_in"}, :omg)
    assert_not path_checker.signing_out?
  end
end