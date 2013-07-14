![Devise Logo](https://raw.github.com/plataformatec/devise/master/devise.png)

By [Plataformatec](http://plataformatec.com.br/).

[![Gem Version](https://fury-badge.herokuapp.com/rb/devise.png)](http://badge.fury.io/rb/devise)
[![Build Status](https://api.travis-ci.org/plataformatec/devise.png?branch=master)](http://travis-ci.org/plataformatec/devise)
[![Code Climate](https://codeclimate.com/github/plataformatec/devise.png)](https://codeclimate.com/github/plataformatec/devise)

This README is [also available in a friendly navigable format](http://devise.plataformatec.com.br/).

Devise is a flexible authentication solution for Rails based on Warden. It:

* Is Rack based;
* Is a complete MVC solution based on Rails engines;
* Allows you to have multiple roles (or models/scopes) signed in at the same time;
* Is based on a modularity concept: use just what you really need.

It's composed of 11 modules:

* [Database Authenticatable](http://rubydoc.info/github/plataformatec/devise/master/Devise/Models/DatabaseAuthenticatable): encrypts and stores a password in the database to validate the authenticity of a user while signing in. The authentication can be done both through POST requests or HTTP Basic Authentication.
* [Token Authenticatable](http://rubydoc.info/github/plataformatec/devise/master/Devise/Models/TokenAuthenticatable): signs in a user based on an authentication token (also known as "single access token"). The token can be given both through query string or HTTP Basic Authentication.
* [Omniauthable](http://rubydoc.info/github/plataformatec/devise/master/Devise/Models/Omniauthable): adds Omniauth (https://github.com/intridea/omniauth) support;
* [Confirmable](http://rubydoc.info/github/plataformatec/devise/master/Devise/Models/Confirmable): sends emails with confirmation instructions and verifies whether an account is already confirmed during sign in.
* [Recoverable](http://rubydoc.info/github/plataformatec/devise/master/Devise/Models/Recoverable): resets the user password and sends reset instructions.
* [Registerable](http://rubydoc.info/github/plataformatec/devise/master/Devise/Models/Registerable): handles signing up users through a registration process, also allowing them to edit and destroy their account.
* [Rememberable](http://rubydoc.info/github/plataformatec/devise/master/Devise/Models/Rememberable): manages generating and clearing a token for remembering the user from a saved cookie.
* [Trackable](http://rubydoc.info/github/plataformatec/devise/master/Devise/Models/Trackable): tracks sign in count, timestamps and IP address.
* [Timeoutable](http://rubydoc.info/github/plataformatec/devise/master/Devise/Models/Timeoutable): expires sessions that have no activity in a specified period of time.
* [Validatable](http://rubydoc.info/github/plataformatec/devise/master/Devise/Models/Validatable): provides validations of email and password. It's optional and can be customized, so you're able to define your own validations.
* [Lockable](http://rubydoc.info/github/plataformatec/devise/master/Devise/Models/Lockable): locks an account after a specified number of failed sign-in attempts. Can unlock via email or after a specified time period.

Devise is guaranteed to be thread-safe on YARV. Thread-safety support on JRuby is on progress.

## Information

### The Devise wiki

The Devise Wiki has lots of additional information about Devise including many "how-to" articles and answers to the most frequently asked questions. Please browse the Wiki after finishing this README:

https://wiki.github.com/plataformatec/devise

### Bug reports

If you discover a problem with Devise, we would like to know about it. However, we ask that you please review these guidelines before submitting a bug report:

https://github.com/plataformatec/devise/wiki/Bug-reports

If you found a security bug, do *NOT* use the GitHub issue tracker. Send an email to the maintainers listed at the bottom of the README.

### Mailing list

If you have any questions, comments, or concerns, please use the Google Group instead of the GitHub issue tracker:

https://groups.google.com/group/plataformatec-devise

### RDocs

You can view the Devise documentation in RDoc format here:

http://rubydoc.info/github/plataformatec/devise/master/frames

If you need to use Devise with previous versions of Rails, you can always run "gem server" from the command line after you install the gem to access the old documentation.

### Example applications

There are a few example applications available on GitHub that demonstrate various features of Devise with different versions of Rails. You can view them here:

https://github.com/plataformatec/devise/wiki/Example-Applications

### Extensions

Our community has created a number of extensions that add functionality above and beyond what is included with Devise. You can view a list of available extensions and add your own here:

https://github.com/plataformatec/devise/wiki/Extensions

### Contributing

We hope that you will consider contributing to Devise. Please read this short overview for some information about how to get started:

https://github.com/plataformatec/devise/wiki/Contributing

You will usually want to write tests for your changes.  To run the test suite, go into Devise's top-level directory and run "bundle install" and "rake".  For the tests to pass, you will need to have a MongoDB server (version 2.0 or newer) running on your system.

## Starting with Rails?

If you are building your first Rails application, we recommend you to *not* use Devise. Devise requires a good understanding of the Rails Framework. In such cases, we advise you to start a simple authentication system from scratch, today we have two resources:

* Michael Hartl's online book: http://railstutorial.org/chapters/modeling-and-viewing-users-two#top
* Ryan Bates' Railscast: http://railscasts.com/episodes/250-authentication-from-scratch

Once you have solidified your understanding of Rails and authentication mechanisms, we assure you Devise will be very pleasant to work with. :)

## Getting started

Devise 3.0 works with Rails 3.2 onwards. You can add it to your Gemfile with:

```ruby
gem 'devise'
```

Run the bundle command to install it.

After you install Devise and add it to your Gemfile, you need to run the generator:

```console
rails generate devise:install
```

The generator will install an initializer which describes ALL Devise's configuration options and you MUST take a look at it. When you are done, you are ready to add Devise to any of your models using the generator:

```console
rails generate devise MODEL
```

Replace MODEL by the class name used for the applications users, it's frequently `User` but could also be `Admin`. This will create a model (if one does not exist) and configure it with default Devise modules. Next, you'll usually run `rake db:migrate` as the generator will have created a migration file (if your ORM supports them). This generator also configures your config/routes.rb file to point to the Devise controller.

Note that you should re-start your app here if you've already started it. Otherwise you'll run into strange errors like users being unable to login and the route helpers being undefined.

### Controller filters and helpers

Devise will create some helpers to use inside your controllers and views. To set up a controller with user authentication, just add this before_filter:

```ruby
before_filter :authenticate_user!
```

To verify if a user is signed in, use the following helper:

```ruby
user_signed_in?
```

For the current signed-in user, this helper is available:

```ruby
current_user
```

You can access the session for this scope:

```ruby
user_session
```

After signing in a user, confirming the account or updating the password, Devise will look for a scoped root path to redirect. Example: For a :user resource, it will use `user_root_path` if it exists, otherwise default `root_path` will be used. This means that you need to set the root inside your routes:

```ruby
root to: "home#index"
```

You can also overwrite `after_sign_in_path_for` and `after_sign_out_path_for` to customize your redirect hooks.

Finally, you need to set up default url options for the mailer in each environment. Here is the configuration for "config/environments/development.rb":

```ruby
config.action_mailer.default_url_options = { :host => 'localhost:3000' }
```

Notice that if your devise model is not called "user" but "member", then the helpers you should use are:

```ruby
before_filter :authenticate_member!

member_signed_in?

current_member

member_session
```

### Configuring Models

The devise method in your models also accepts some options to configure its modules. For example, you can choose the cost of the encryption algorithm with:

```ruby
devise :database_authenticatable, :registerable, :confirmable, :recoverable, :stretches => 20
```

Besides :stretches, you can define :pepper, :encryptor, :confirm_within, :remember_for, :timeout_in, :unlock_in and other values. For details, see the initializer file that was created when you invoked the "devise:install" generator described above.

### Strong Parameters

When you customize your own views, you may end up adding new attributes to forms. Rails 4 moved the parameter sanitization from the model to the controller, causing Devise to handle this concern at the controller as well.

There are just three actions in Devise that allows any set of parameters to be passed down to the model, therefore requiring sanitization. Their names and the permited parameters by default are:

* `sign_in` (`Devise::SessionsController#new`) - Permits only the authentication keys (like `email`)
* `sign_up` (`Devise::RegistrationsController#create`) - Permits authentication keys plus `password` and `password_confirmation`
* `account_update` (`Devise::RegistrationsController#update`) - Permits authentication keys plus `password`, `password_confirmation` and `current_password`

In case you want to customize the permitted parameters (the lazy way™) you can do with a simple before filter in your `ApplicationController`:

```ruby
class ApplicationController < ActionController::Base
  before_filter :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:username, :email) }
  end
end
```

If you have multiple roles, you may want to set up different parameter sanitizer per role. In this case, we recommend inheriting from `Devise::ParameterSanitizer` and add your own logic:

```ruby
class User::ParameterSanitizer < Devise::ParameterSanitizer
  def sign_in
    default_params.permit(:username, :email)
  end
end
```

And then configure your controllers to use it:

```ruby
class ApplicationController < ActionController::Base
  protected

  def devise_parameter_sanitizer
    if resource_class == User
      User::ParameterSanitizer.new(User, :user, params)
    else
      super # Use the default one
    end
  end
end
```

The example above overrides the permitted parameters for the user to be both `:username` and `:email`. The non-lazy way to configure parameters would be by defining the before filter above in a custom controller. We detail how to configure and customize controllers in some sections below.

### Configuring views

We built Devise to help you quickly develop an application that uses authentication. However, we don't want to be in your way when you need to customize it.

Since Devise is an engine, all its views are packaged inside the gem. These views will help you get started, but after some time you may want to change them. If this is the case, you just need to invoke the following generator, and it will copy all views to your application:

```console
rails generate devise:views
```

If you have more than one role in your application (such as "User" and "Admin"), you will notice that Devise uses the same views for all roles. Fortunately, Devise offers an easy way to customize views. All you need to do is set "config.scoped_views = true" inside "config/initializers/devise.rb".

After doing so, you will be able to have views based on the role like "users/sessions/new" and "admins/sessions/new". If no view is found within the scope, Devise will use the default view at "devise/sessions/new". You can also use the generator to generate scoped views:

```console
rails generate devise:views users
```

### Configuring controllers

If the customization at the views level is not enough, you can customize each controller by following these steps:

1. Create your custom controller, for example a `Admins::SessionsController`:  

    ```ruby
    class Admins::SessionsController < Devise::SessionsController
    end
    ```

    Note that in the above example, the controller needs to be created in the `app/controller/admins/` directory.

2. Tell the router to use this controller:

    ```ruby
    devise_for :admins, :controllers => { :sessions => "admins/sessions" }
    ```

3. And since we changed the controller, it won't use the `"devise/sessions"` views, so remember to copy `"devise/sessions"` to `"admin/sessions"`.

    Remember that Devise uses flash messages to let users know if sign in was successful or failed. Devise expects your application to call `"flash[:notice]"` and `"flash[:alert]"` as appropriate. Do not print the entire flash hash, print specific keys or at least remove the `:timedout` key from the hash as Devise adds this key in some circumstances, this key is not meant for display.

### Configuring routes

Devise also ships with default routes. If you need to customize them, you should probably be able to do it through the devise_for method. It accepts several options like :class_name, :path_prefix and so on, including the possibility to change path names for I18n:

```ruby
devise_for :users, :path => "auth", :path_names => { :sign_in => 'login', :sign_out => 'logout', :password => 'secret', :confirmation => 'verification', :unlock => 'unblock', :registration => 'register', :sign_up => 'cmon_let_me_in' }
```

Be sure to check `devise_for` documentation for details.

If you have the need for more deep customization, for instance to also allow "/sign_in" besides "/users/sign_in", all you need to do is to create your routes normally and wrap them in a `devise_scope` block in the router:

```ruby
devise_scope :user do
  get "sign_in", :to => "devise/sessions#new"
end
```

This way you tell devise to use the scope :user when "/sign_in" is accessed. Notice `devise_scope` is also aliased as `as` in your router.

### I18n

Devise uses flash messages with I18n with the flash keys :notice and :alert. To customize your app, you can set up your locale file:

```yaml
en:
  devise:
    sessions:
      signed_in: 'Signed in successfully.'
```

You can also create distinct messages based on the resource you've configured using the singular name given in routes:

```yaml
en:
  devise:
    sessions:
      user:
        signed_in: 'Welcome user, you are signed in.'
      admin:
        signed_in: 'Hello admin!'
```

The Devise mailer uses a similar pattern to create subject messages:

```yaml
en:
  devise:
    mailer:
      confirmation_instructions:
        subject: 'Hello everybody!'
        user_subject: 'Hello User! Please confirm your email'
      reset_password_instructions:
        subject: 'Reset instructions'
```

Take a look at our locale file to check all available messages. You may also be interested in one of the many translations that are available on our wiki:

https://github.com/plataformatec/devise/wiki/I18n

### Test helpers

Devise includes some tests helpers for functional specs. In order to use them, you need to include Devise in your functional tests by adding the following to the bottom of your `test/test_helper.rb` file:

```ruby
class ActionController::TestCase
  include Devise::TestHelpers
end
```

If you're using RSpec, you can put the following inside a file named `spec/support/devise.rb`:

```ruby
RSpec.configure do |config|
  config.include Devise::TestHelpers, :type => :controller
end
```

Now you are ready to use the `sign_in` and `sign_out` methods. Such methods have the same signature as in controllers:

```ruby
sign_in :user, @user   # sign_in(scope, resource)
sign_in @user          # sign_in(resource)

sign_out :user         # sign_out(scope)
sign_out @user         # sign_out(resource)
```

There are two things that is important to keep in mind:

1. These helpers are not going to work for integration tests driven by Capybara or Webrat. They are meant to be used with functional tests only. Instead, fill in the form or explicitly set the user in session;

2. If you are testing Devise internal controllers or a controller that inherits from Devise's, you need to tell Devise which mapping should be used before a request. This is necessary because Devise gets this information from router, but since functional tests do not pass through the router, it needs to be told explicitly. For example, if you are testing the user scope, simply do:

    ```ruby
    @request.env["devise.mapping"] = Devise.mappings[:user]
    get :new
    ```

### Omniauth

Devise comes with Omniauth support out of the box to authenticate with other providers. To use it, just specify your omniauth configuration in `config/initializers/devise.rb`:

```ruby
config.omniauth :github, 'APP_ID', 'APP_SECRET', :scope => 'user,public_repo'
```

You can read more about Omniauth support in the wiki:

* https://github.com/plataformatec/devise/wiki/OmniAuth:-Overview

### Configuring multiple models

Devise allows you to set up as many roles as you want. For example, you may have a User model and also want an Admin model with just authentication and timeoutable features. If so, just follow these steps:

```ruby
# Create a migration with the required fields
create_table :admins do |t|
  t.string :email
  t.string :encrypted_password
  t.timestamps
end

# Inside your Admin model
devise :database_authenticatable, :timeoutable

# Inside your routes
devise_for :admins

# Inside your protected controller
before_filter :authenticate_admin!

# Inside your controllers and views
admin_signed_in?
current_admin
admin_session
```

On the other hand, you can simply run the generator!

### Other ORMs

Devise supports ActiveRecord (default) and Mongoid. To choose other ORM, you just need to require it in the initializer file.

## Additional information

### Heroku

Using devise on Heroku with Ruby on Rails 3.1 requires setting:

```ruby
config.assets.initialize_on_precompile = false
```

Read more about the potential issues at http://guides.rubyonrails.org/asset_pipeline.html

### Warden

Devise is based on Warden, which is a general Rack authentication framework created by Daniel Neighman. We encourage you to read more about Warden here:

https://github.com/hassox/warden

### Contributors

We have a long list of valued contributors. Check them all at:

https://github.com/plataformatec/devise/contributors

### Maintainers

* José Valim (https://github.com/josevalim)
* Carlos Antônio da Silva (https://github.com/carlosantoniodasilva)
* Rodrigo Flores (https://github.com/rodrigoflores)

## License

MIT License. Copyright 2009-2013 Plataformatec. http://plataformatec.com.br

You are not granted rights or licenses to the trademarks of the Plataformatec, including without limitation the Devise name or logo.
