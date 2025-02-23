# frozen_string_literal: true

require 'test_helper'

class ActivatableTest < Devise::IntegrationTest
  test 'shows the localized error message for inactive accounts' do
    store_translations(
      en: { devise: { failure: { unconfirmed: 'Unconfirmed account.' } } },
      de: { devise: { failure: { unconfirmed: 'Unbestätigtes Konto!' } } }
    ) do
      I18n.with_locale(:de) do
        user = create_user(confirm: false, confirmation_sent_at: 1.hour.ago)
        get new_user_session_path
        fill_in 'email', with: user.email
        fill_in 'password', with: user.password
        click_button 'Log In'

        assert_contain('Unbestätigtes Konto!')
      end
    end
  end
end
