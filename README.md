# Fb::Jwt::Auth

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fb-jwt-auth'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install fb-jwt-auth

## Usage

```
Fb::Jwt::Auth.configure do |config|
  config.service_token_cache_root_url = ENV['SERVICE_TOKEN_CACHE_ROOT_URL']
end

Fb::Jwt::Auth.new(
  access_token: request.headers['x-access-token-v2'],
  key: 'fb-editor', # service name
  leeway: ENV['MAX_IAT_SKEW_SECONDS'],
  logger: Rails.logger
).verify!
```
