require 'fb/jwt/auth/version'
require 'openssl'
require 'jwt'
require 'active_support/core_ext'

module Fb
  module Jwt
    class Auth
      cattr_accessor :service_token_cache_root_url, :service_token_cache_api_version

      def self.configure(&block)
        yield self
      end

      autoload :ServiceTokenClient, 'fb/jwt/auth/service_token_client'

      class TokenNotPresentError < StandardError
      end

      class TokenNotValidError < StandardError
      end

      class TokenExpiredError < StandardError
      end

      class IssuerNotPresentError < StandardError
      end

      class NamespaceNotPresentError < StandardError
      end

      attr_accessor :token, :key, :leeway, :logger

      def initialize(token:, key: nil, leeway:, logger:)
        @token = token
        @key = key
        @leeway = leeway
        @logger = logger
      end

      def verify!
        raise TokenNotPresentError if token.nil?

        application_details = find_application_info

        begin
          hmac_secret = public_key(application_details)
          payload, _header = decode(hmac_secret: hmac_secret)
        rescue StandardError => e
          error_message = "Couldn't parse that token - error #{e}"
          logger.debug(error_message)
          raise TokenNotValidError.new(error_message)
        end

        # NOTE: verify_iat used to be in the JWT gem, but was removed in v2.2
        # so we have to do it manually
        iat_skew = payload['iat'].to_i - Time.zone.now.to_i

        if iat_skew.abs > leeway.to_i
          error_message = "iat skew is #{iat_skew}, max is #{leeway} - INVALID"
          logger.debug(error_message)

          raise TokenExpiredError.new(error_message)
        end

        logger.debug 'token is valid'
        payload
      end

      def decode(verify: true, hmac_secret: nil)
        JWT.decode(
          token,
          hmac_secret,
          verify,
          exp_leeway: leeway,
          algorithm: 'RS256'
        )
      end

      def find_application_info
        return { application: key } if key

        payload, _header = decode(verify: false)
        application = payload['iss']
        namespace = payload['namespace']

        raise IssuerNotPresentError unless application
        raise NamespaceNotPresentError unless namespace

        { application: application, namespace: namespace}
      end

      def public_key(attributes)
        OpenSSL::PKey::RSA.new(
          ServiceTokenClient.new(attributes).public_key
        )
      end
    end
  end
end
