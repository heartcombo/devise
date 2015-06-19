module StubModelFilters
  def stub_filter(name)
    define_singleton_method(name) { |*| nil }
  end
end
