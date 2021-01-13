module Fb
  module Jwt
    class Auth
      class ServiceAccessToken
        attr_reader :encoded_private_key,
                    :issuer,
                    :subject,
                    :namespace

        def initialize(subject: nil)
          @subject = subject
          @encoded_private_key = Fb::Jwt::Auth.encoded_private_key
          @namespace = Fb::Jwt::Auth.namespace
          @issuer = Fb::Jwt::Auth.issuer
        end

        def generate
          return '' if encoded_private_key.blank?

          private_key = OpenSSL::PKey::RSA.new(encoded_private_key.chomp)

          JWT.encode(
            token,
            private_key,
            'RS256'
          )
        end

        private

        def token
          payload = {
            iss: issuer,
            iat: Time.current.to_i
          }
          payload[:sub] = subject if subject.present?
          payload[:namespace] = namespace if namespace.present?
          payload
        end
      end
    end
  end
end
