require 'test_helper'

class DeviseHelperTest < ActionController::IntegrationTest
  setup do
    model_labels = { :models => { :user => "utilisateur" } }

    I18n.backend.store_translations :fr,
    {
      :errors => { :messages => { :not_saved => {
        :one => "Erreur lors de l'enregistrement de '%{resource}': 1 erreur.",
        :other => "Erreur lors de l'enregistrement de '%{resource}': %{count} erreurs."
      } } },
      # Required to prevent tests from blowing up when they don't find
      # the I18n version of the "Sign up" button.
      #
      # I haven't worked out why both are required yet but it looks like one
      # supplies the string to the button, one to the test.
      :sign_up => 'Connectez',
      :devise => { :registrations => { :new => { :sign_up => 'Connectez' } } },
      :activerecord => model_labels,
      :mongoid => model_labels
    }

    I18n.locale = 'fr'
  end

  teardown do
    I18n.locale = 'en'
  end

  test 'test errors.messages.not_saved with single error from i18n' do
    get new_user_registration_path

    fill_in 'password', :with => 'new_user123'
    fill_in 'password confirmation', :with => 'new_user123'
    click_button I18n.t('.sign_up')

    assert_have_selector '#error_explanation'
    assert_contain "Erreur lors de l'enregistrement de 'utilisateur': 1 erreur"
  end

  test 'test errors.messages.not_saved with multiple errors from i18n' do
    # Dirty tracking behavior prevents email validations from being applied:
    #    https://github.com/mongoid/mongoid/issues/756
    (pending "Fails on Mongoid < 2.1"; break) if defined?(Mongoid) && Mongoid::VERSION.to_f < 2.1

    get new_user_registration_path

    fill_in 'email', :with => 'invalid_email'
    fill_in 'password', :with => 'new_user123'
    fill_in 'password confirmation', :with => 'new_user321'
    click_button I18n.t('.sign_up')

    assert_have_selector '#error_explanation'
    assert_contain "Erreur lors de l'enregistrement de 'utilisateur': 2 erreurs"
  end
end

