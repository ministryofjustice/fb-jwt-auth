RSpec.describe Fb::Jwt::Auth do
  describe '#verify!' do
    let(:logger) { Logger.new(STDOUT) }
    let(:iat) { Time.now.to_i }
    let(:editor_client_private_key) do
      OpenSSL::PKey::RSA.generate 2048
    end
    let(:client_public_key) do
      editor_client_private_key.public_key
    end
    let(:payload) do
      { iat: iat, sub: 'luke', iss: 'greedo' }
    end
    let(:token) do
      JWT.encode payload, editor_client_private_key, 'RS256'
    end
    let(:key) { 'fb-editor' }
    let(:auth) do
      described_class.new(
        token: token,
        key: key,
        leeway: 60,
        logger: logger
      )
    end
    let(:service_token_client) do
      double(public_key: client_public_key)
    end

    context 'v3 with issuer in the JWT payload' do
      let(:payload) do
        { iat: iat, sub: 'luke', iss: 'greedo', namespace: 'fb-awesome' }
      end
      let(:v3_auth) do
        described_class.new(
          token: token,
          leeway: 60,
          logger: logger
        )
      end

      context 'with valid token' do
        it 'returns the correct payload' do
          allow(
            Fb::Jwt::Auth::ServiceTokenClient
          ).to receive(:new).with(
            application: 'greedo',
            namespace: 'fb-awesome'
          ).and_return(service_token_client)

          result = v3_auth.verify!

          expect(result).to eq({
            'iss' => 'greedo', 'iat'=> iat, 'sub' => 'luke', 'namespace' => 'fb-awesome'
          })
        end
      end

      context 'when issuer is not in the v3 JWT payload' do
        let(:payload) do
          { iat: iat, sub: 'luke' }
        end

        it 'should raise a IssuerNotPresentError' do
          expect { v3_auth.verify! }.to raise_error(Fb::Jwt::Auth::IssuerNotPresentError, 'Issuer is not present in the token')
        end
      end

      context 'when namespace is not in the v3 JWT payload' do
        let(:payload) do
          { iat: iat, sub: 'luke', iss: 'baby_yoda' }
        end

        it 'should raise a NamespaceNotPresentError' do
          expect { v3_auth.verify! }.to raise_error(Fb::Jwt::Auth::NamespaceNotPresentError, 'Namespace is not present in the token')
        end
      end
    end

    context 'v2 with key as passed in separately' do
      context 'when valid token' do
        it 'returns payload' do
          allow(
            Fb::Jwt::Auth::ServiceTokenClient
          ).to receive(:new).with(application: key).and_return(service_token_client)

          result = auth.verify!

          expect(result).to eq({
            'iss' => 'greedo', 'iat'=> iat, 'sub' => 'luke'
          })
        end
      end
    end

    context 'when invalid token' do
      context 'when token is not present' do
        let(:token) { nil }

        it 'should raise a TokenNotPresentError error' do
          expect { auth.verify! }.to raise_error(Fb::Jwt::Auth::TokenNotPresentError, 'Token is not present')
        end
      end

      context 'when token is expired' do
        let(:iat) { (Time.now - 61).to_i }

        it 'should raise TokenExpiredError' do
          allow(
            Fb::Jwt::Auth::ServiceTokenClient
          ).to receive(:new).with(application: key).and_return(service_token_client)

          expect { auth.verify! }.to raise_error(Fb::Jwt::Auth::TokenExpiredError, /Token has expired/)
        end
      end

      context 'when token raises TokenNotValidError error' do
        let(:fake_client_private_key) do
          OpenSSL::PKey::RSA.generate 2048
        end
        let(:fake_client_public_key) do
          fake_client_private_key.public_key
        end
        let(:service_token_client) do
          double(public_key: fake_client_public_key)
        end

        it 'should raise a TokenNotValidError error' do
          allow(
            Fb::Jwt::Auth::ServiceTokenClient
          ).to receive(:new).with(application: key).and_return(service_token_client)

          expect { auth.verify! }.to raise_error(Fb::Jwt::Auth::TokenNotValidError, /Token is not valid/)
        end
      end
    end
  end
end
