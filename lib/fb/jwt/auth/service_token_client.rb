require 'net/http'
require 'json'
require 'base64'

class Fb::Jwt::Auth::ServiceTokenClient
  class ServiceTokenCacheError < StandardError; end

  attr_accessor :key, :root_url

  def initialize(key)
    @key = key
    @root_url = Fb::Jwt::Auth.service_token_cache_root_url
  end

  def public_key
    response = Net::HTTP.get_response(public_key_uri)

    unless response.code.to_i == 200
      raise ServiceTokenCacheError.new(
        "Unexpected response code\n" \
        "Response code: #{response.code} => Response body: #{response.body}"
      )
    end

    Base64.strict_decode64(JSON.parse(response.body).fetch('token'))
  rescue Errno::ECONNREFUSED => e
    raise ServiceTokenCacheError.new(
      "Unable to connect to the Service Token Cache\n#{e.message}"
    )
  end

  private

  def public_key_uri
    URI.join(@root_url, '/service/v2/', key)
  end
end
