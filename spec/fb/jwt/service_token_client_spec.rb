RSpec.describe Fb::Jwt::Auth::ServiceTokenClient do
  before do
    Fb::Jwt::Auth.configure do |config|
      config.service_token_cache_root_url = 'http://localhost:4000'
    end
  end

  context 'when public key exists' do
    let(:public_key_uri) { URI('http://localhost:4000/service/v2/some-key') }
    let(:service_token_client) { described_class.new('some-key') }
    let(:response) do
      double(code: 200, body: JSON.generate(token: Base64.strict_encode64('R2D2')))
    end

    it 'should return a base64 decoded public key' do
      allow(Net::HTTP).to receive(:get_response).with(public_key_uri).and_return(response)
      expect(service_token_client.public_key).to eq('R2D2')
    end
  end
end
