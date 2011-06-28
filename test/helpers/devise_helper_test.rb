require 'test_helper'

class DeviseHelperTest < ActionController::IntegrationTest
  setup do
    I18n.backend.store_translations :fr,
    {
      :errors => { :messages => { :not_saved => {
        :one => "Erreur lors de l'enregistrement de '%{resource}': 1 erreur.",
        :other => "Erreur lors de l'enregistrement de '%{resource}': %{count} erreurs."
      } } },
      :activerecord => { :models => { :user => "utilisateur" } }
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
    click_button 'Sign up'

    assert_have_selector '#error_explanation'
    assert_contain "Erreur lors de l'enregistrement de 'utilisateur': 1 erreur"
  end

  test 'test errors.messages.not_saved with multiple errors from i18n' do
    get new_user_registration_path

    fill_in 'email', :with => 'invalid_email'
    fill_in 'password', :with => 'new_user123'
    fill_in 'password confirmation', :with => 'new_user321'
    click_button 'Sign up'

    assert_have_selector '#error_explanation'
    assert_contain "Erreur lors de l'enregistrement de 'utilisateur': 2 erreurs"
  end
end