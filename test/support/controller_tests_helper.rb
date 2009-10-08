class ActionController::TestCase

  def translated_route(translation={}, &block)
    I18n.locale = :'pt-BR'
    I18n.backend.store_translations(:'pt-BR', :devise => { :routes => translation })
    ActionController::Routing::Routes.reload!
    yield
    I18n.locale = :en
    I18n.reload!
    ActionController::Routing::Routes.reload!
  end
end
