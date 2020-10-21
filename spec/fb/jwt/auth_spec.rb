RSpec.describe Fb::Jwt::Auth do
  describe '#verify!' do
    let(:logger) { Logger.new(STDOUT) }
    let(:iat) { Time.now.to_i }

    context 'when valid token' do
      let(:editor_client_private_key) do
        OpenSSL::PKey::RSA.generate 2048
      end
      let(:editor_client_public_key) do
        editor_client_private_key.public_key
      end
      let(:payload) do
        { iat: iat, sub: 'luke', characters: [:greedo, :jabba, :han_solo] }
      end
      let(:token) do
        JWT.encode payload, editor_client_private_key, 'RS256'
      end
      let(:key) { 'fb-editor' }

      it 'returns payload' do
        auth = described_class.new(
          token: token,
          key: key,
          leeway: 60,
          logger: logger
        )

        allow(auth).to receive(:public_key).with(key).and_return(editor_client_public_key)

        result = auth.verify!

        expect(result).to eq({
          'characters' => ['greedo', 'jabba', 'han_solo'], 'iat'=> iat, 'sub' => 'luke'
        })
      end
    end
  end
end