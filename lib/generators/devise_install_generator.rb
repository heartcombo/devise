# Remove this file after deprecation
if caller.none? { |l| l =~ %r{lib/rails/generators\.rb:(\d+):in `lookup!'$} }
  warn "[WARNING] `rails g devise_install` is deprecated, please use `rails g devise:install` instead."
end