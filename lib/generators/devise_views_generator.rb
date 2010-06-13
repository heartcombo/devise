# Remove this file after deprecation
if caller.none? { |l| l =~ %r{lib/rails/generators\.rb:(\d+):in `lookup!'$} }
  warn "[WARNING] `rails g devise_views` is deprecated, please use `rails g devise:views` instead."
end