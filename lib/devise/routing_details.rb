module Devise
  # This is a data transfer object to avoid coupling between
  # Devive::Mapping and the rest of the application.
  class RoutingDetails
    attr_reader :scope, :router_name

    def initialize(mapping)
      @scope = mapping.name
      @router_name = mapping.router_name
    end
  end
end
