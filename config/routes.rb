ActionController::Routing::Routes.draw do |map|
  Devise.mappings.each_value do |mapping|
    map.namespace mapping.name, :namespace => nil, :path_prefix => mapping.as do |m|
      if mapping.authenticable?
        m.resource :session,
                   :only => [:new, :create, :destroy]
      end

      if mapping.recoverable?
        m.resource :password,
                   :only => [:new, :create, :edit, :update]
      end

      if mapping.confirmable?
        m.resource :confirmation,
                   :only => [:new, :create, :show]
      end
    end
  end
end
