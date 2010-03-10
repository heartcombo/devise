class DeviseViewsGenerator < Rails::Generators::Base
  desc "Copies all Devise views to your application."

  argument :scope, :required => false, :default => nil,
                   :desc => "The scope to copy views to"

  def self.source_root
    @_devise_source_root ||= File.expand_path("../../../../app/views", __FILE__)
  end

  def copy_views
    directory "devise", "app/views/devise/#{scope}"
  end
end