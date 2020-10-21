require 'net/http'
require 'json'
require 'base64'

class Fb::Jwt::Auth::ServiceTokenClient
  attr_accessor :key, :root_url

  def initialize(key)
    @key = key
    @root_url = Fb::Jwt::Auth.service_token_cache_root_url
  end

  def public_key
    response = Net::HTTP.get_response(public_key_uri)

    # improve when service token cache returns error response (timeout, 400,
    # 500)
    return unless response.code.to_i == 200

    Base64.strict_decode64(JSON.parse(response.body).fetch('token'))
  end

  private

  def public_key_uri
    URI.join(@root_url, '/service/v2/', key)
  end
end