source 'https://rubygems.org'

group :development do
  gem 'guard-rspec'
  gem 'pry'
  gem 'pry-rescue'
  platforms :ruby_19, :ruby_20 do
    gem 'pry-debugger'
    gem 'pry-stack_explorer'
  end
end

group :test do
  gem 'coveralls', :require => false
  gem 'rspec', '>= 2.14'
  gem 'rubocop', '>= 0.16', :platforms => [:ruby_19, :ruby_20]
  gem 'simplecov', :require => false
  gem 'timecop'
  gem 'webmock', '>= 1.10.1'
end

gemspec

