RSpec.describe Fb::Jwt::Auth::ServiceAccessToken do
  let(:private_key) { OpenSSL::PKey::RSA.generate(2048) }
  let(:encoded_private_key) do
    Base64.strict_encode64(private_key.to_s)
  end
  let(:public_key) { private_key.public_key }
  let(:current_time) { Time.new(2020, 12, 7, 16) }

  describe '#generate' do
    let(:subject) { nil }
    let(:namespace) { nil }
    let(:issuer) { 'fb-editor' }
    let(:service_token) do
      described_class.new(
        subject: subject
      )
    end

    before do
      allow(Fb::Jwt::Auth).to receive(:issuer).and_return(issuer)
      allow(Fb::Jwt::Auth).to receive(:namespace).and_return(namespace)
      allow(Fb::Jwt::Auth).to receive(:encoded_private_key).and_return(
        encoded_private_key
      )
      allow(Time).to receive(:current).and_return(current_time)
    end

    context 'when private key is blank' do
      let(:encoded_private_key) { {} }
      let(:subject) { nil }

      it 'returns nil' do
        expect(service_token.generate).to eq('')
      end
    end

    context 'when there is a subject' do
      let(:subject) { 'user-id-123' }

      it 'generates jwt access token with a sub' do
        expect(
          JWT.decode(service_token.generate, public_key, true, { algorithm: 'RS256' })
        ).to eq([
          {
            'iat' => current_time.to_i,
            'iss' => 'fb-editor',
            'sub' => 'user-id-123'
          },
          {
            'alg' => 'RS256'
          }
        ])
      end
    end

    context 'when there is no subject ' do
      let(:subject) { nil }

      it 'generate jwt access token without a sub' do
        expect(
          JWT.decode(service_token.generate, public_key, true, { algorithm: 'RS256' })
        ).to eq([
          {
            'iat' => current_time.to_i,
            'iss' => 'fb-editor'
          },
          {
            'alg' => 'RS256'
          }
        ])
      end
    end

    context 'when there is a namespace' do
      let(:subject) { nil }
      let(:namespace) { 'formbuilder-saas-test' }

      it 'generate jwt access token without a sub' do
        expect(
          JWT.decode(service_token.generate, public_key, true, { algorithm: 'RS256' })
        ).to eq([
          {
            'iat' => current_time.to_i,
            'iss' => 'fb-editor',
            'namespace' => 'formbuilder-saas-test'
          },
          {
            'alg' => 'RS256'
          }
        ])
      end
    end
  end
end
