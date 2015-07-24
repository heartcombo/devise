config = Rails.application.config

if Devise.rails4?
  config.secret_key_base = 'd588e99efff13a86461fd6ab82327823ad2f8feb5dc217ce652cdd9f0dfc5eb4b5a62a92d24d2574d7d51dfb1ea8dd453ea54e00cf672159a13104a135422a10'
else
  config.secret_token = 'ea942c41850d502f2c8283e26bdc57829f471bb18224ddff0a192c4f32cdf6cb5aa0d82b3a7a7adbeb640c4b06f3aa1cd5f098162d8240f669b39d6b49680571'
  config.session_store :cookie_store, key: '_my_app'
end
