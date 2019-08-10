# frozen_string_literal: true

require 'test_helper'

module MyMountableEngine
  class Engine < ::Rails::Engine
    isolate_namespace MyMountableEngine
  end
  class TestsController < ActionController::Base
    def index
      render plain: 'Root test successful'
    end
    def inner_route
      render plain: 'Inner route test successful'
    end
  end
end

MyMountableEngine::Engine.routes.draw do
  get 'test', to: 'tests#inner_route'
  root to: 'tests#index'
end

# If disable_clear_and_finalize is set to true, Rails will not clear other routes when calling
# again the draw method. Look at the source code at:
# http://www.rubydoc.info/docs/rails/ActionDispatch/Routing/RouteSet:draw
Rails.application.routes.disable_clear_and_finalize = true

Rails.application.routes.draw do
  authenticate(:user) do
    mount MyMountableEngine::Engine, at: '/mountable_engine'
  end
end

class AuthenticatedMountedEngineTest < Devise::IntegrationTest
  test 'redirects to the sign in page when not authenticated' do
    get '/mountable_engine'
    follow_redirect!

    assert_response :ok
    assert_contain 'You need to sign in or sign up before continuing.'
  end

  test 'renders the mounted engine when authenticated' do
    sign_in_as_user
    get '/mountable_engine'

    assert_response :success
    assert_contain 'Root test successful'
  end


  test 'renders a inner route of the mounted engine when authenticated' do
    sign_in_as_user
    get '/mountable_engine/test'

    assert_response :success
    assert_contain 'Inner route test successful'
  end

  test 'respond properly to a non existing route of the mounted engine' do
    sign_in_as_user
    
    assert_raise ActionController::RoutingError do
      get '/mountable_engine/non-existing-route'
    end
  end
end
