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

```ruby
Fb::Jwt::Auth.configure do |config|
  # Service token cache domain
  #
  config.service_token_cache_root_url = ENV['SERVICE_TOKEN_CACHE_ROOT_URL']
end
```
In order to generate the service access token we need to use `Fb::Jwt::Auth::ServiceAccessToken.new.generate` or if you require a subject, `Fb::Jwt::Auth::ServiceAccessToken.new(subject: subject).generate`

In the case you need to configure the service access token as a client
```ruby
Fb::Jwt::Auth.configure do |config|
  config.issuer = 'fb-editor'
  config.namespace = 'formbuilder-saas-test'
  config.encoded_private_key = 'base64 encoded private key'
end
```

### Using other endpoint versions

Service token cache can have different versions of authenticating a service.

You can configure the version:

```ruby
Fb::Jwt::Auth.configure do |config|
  config.service_token_cache_api_version = :v3
end
```

### Verifying the token

```ruby
Fb::Jwt::Auth.new(
  access_token: request.headers['x-access-token-v2'],
  key: 'fb-editor', # service name
  leeway: ENV['MAX_IAT_SKEW_SECONDS'],
  logger: Rails.logger
).verify!
```
