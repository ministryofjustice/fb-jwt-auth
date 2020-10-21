require 'fb/jwt/auth/version'
require 'openssl'
require 'jwt'
require 'active_support/core_ext'

module Fb
  module Jwt
    class Auth
      def self.service_token_cache_root_url=(value)
        @@service_token_cache_root_url = value
      end

      def self.service_token_cache_root_url
        @@service_token_cache_root_url
      end

      def self.configure(&block)
        yield self
      end

      autoload :ServiceTokenService, 'fb/jwt/auth/service_token_service'

      class TokenNotPresentError < StandardError
      end

      class TokenNotValidError < StandardError
      end

      class TokenExpiredError < StandardError
      end

      attr_accessor :token, :key, :leeway, :logger

      def initialize(token:, key:, leeway:, logger:)
        @token = token
        @key = key
        @leeway = leeway
        @logger = logger
      end

      def verify!
        begin
          hmac_secret = public_key(key)
          payload, _header = JWT.decode(
            token,
            hmac_secret,
            true,
            exp_leeway: leeway,
            algorithm: 'RS256'
          )

          # NOTE: verify_iat used to be in the JWT gem, but was removed in v2.2
          # so we have to do it manually
          iat_skew = payload['iat'].to_i - Time.zone.now.to_i

          if iat_skew.abs > leeway.to_i
            logger.debug("iat skew is #{iat_skew}, max is #{leeway} - INVALID")

            raise TokenExpiredError
          end

          logger.debug 'token is valid'
          payload
        rescue StandardError => e
          logger.debug("Couldn't parse that token - error #{e}")
          raise TokenNotValidError
        end
      end

      def public_key
        OpenSSL::PKey::RSA.new(ServiceTokenService.new(key).public_key)
      end
    end
  end
end
