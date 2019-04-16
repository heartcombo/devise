appraise 'rails-4.1-stable' do
  gem 'bundler', '< 2'

  gem 'rails', '~> 4.1.0'
  group :mongoid do
    gem "mongoid"
  end
end if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('1.9.3')

appraise 'rails-4.2-stable' do
  gem 'bundler', '< 2'

  gem 'rails', '~> 4.2.0'
  group :mongoid do
    gem "mongoid"
  end
end if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('1.9.3')

appraise 'rails-5.0-stable' do
  gem 'rails', '~> 5.0.0'
  gem 'activemodel-serializers-xml'
  gem "rails-controller-testing"
  group :mongoid do
    gem "mongoid", "~> 6.0"
  end
end if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('2.2.2')

appraise 'rails-5.1-stable' do
  gem 'rails', '~> 5.1.0'
  gem 'activemodel-serializers-xml'
  gem "rails-controller-testing"
  group :mongoid do
    gem "mongoid", "~> 6.0"
  end
end if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('2.2.2')

appraise 'rails-5.2-stable' do
  gem 'rails', '~> 5.2.0'
  gem 'activemodel-serializers-xml'
  gem "rails-controller-testing"
  group :mongoid do
    gem "mongoid", "~> 6.0"
  end
end if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('2.2.2')

appraise 'rails-6.0-beta' do
  gem 'rails', '6.0.0.beta3'
  gem 'activemodel-serializers-xml'
  gem "rails-controller-testing"
  group :mongoid do
    gem "mongoid", "~> 6.0"
  end
end if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('2.5')
