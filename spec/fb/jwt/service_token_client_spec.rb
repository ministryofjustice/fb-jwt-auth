RSpec.describe Fb::Jwt::Auth::ServiceTokenClient do
  before do
    Fb::Jwt::Auth.configure do |config|
      config.service_token_cache_root_url = 'http://localhost:4000'
    end
  end

  let(:service_token_client) do
    described_class.new(application: 'some-key')
  end
  let(:public_key_uri) { URI('http://localhost:4000/service/v2/some-key') }

  context 'when public key exists' do
    let(:response) do
      double(code: 200, body: JSON.generate(token: Base64.strict_encode64('R2D2')))
    end

    it 'should return a base64 decoded public key' do
      allow(Net::HTTP).to receive(:get_response).with(public_key_uri).and_return(response)
      expect(service_token_client.public_key).to eq('R2D2')
    end
  end

  context 'when the service token cache response is not 200' do
    context 'when Errno::ECONNREFUSED error' do
      it 'should raise ServiceTokenCacheError with helpful message' do
        allow(Net::HTTP).to receive(:get_response).and_raise(Errno::ECONNREFUSED)

        expect {
          service_token_client.public_key
        }.to raise_error(Fb::Jwt::Auth::ServiceTokenClient::ServiceTokenCacheError)
      end
    end

    context 'when response code is 500' do
      let(:response) { double(code: 500, body: 'Error message') }
      let(:error_message) do
        "Unexpected response code\n" \
        "Response code: #{response.code} => Response body: #{response.body}"
      end

      it 'should raise ServiceTokenCacheError containing response code and body' do
        allow(Net::HTTP).to receive(:get_response).with(public_key_uri).and_return(response)

        expect {
          service_token_client.public_key
        }.to raise_error(
          Fb::Jwt::Auth::ServiceTokenClient::ServiceTokenCacheError, error_message
        )
      end
    end
  end

  context 'when requesting v3' do
    let(:service_token_client) do
      described_class.new(application: 'some-key', namespace: 'some-namespace')
    end
    before do
      Fb::Jwt::Auth.configure do |config|
        config.service_token_cache_api_version = :v3
      end
    end

    after do
      Fb::Jwt::Auth.configure do |config|
        config.service_token_cache_api_version = nil
      end
    end

    let(:public_key_uri) { URI('http://localhost:4000/v3/applications/some-key/namespaces/some-namespace') }

    let(:response) do
      double(code: 200, body: JSON.generate(token: Base64.strict_encode64('R2D2')))
    end

    it 'should return a base64 decoded public key' do
      allow(Net::HTTP).to receive(:get_response).with(public_key_uri).and_return(response)
      expect(service_token_client.public_key).to eq('R2D2')
    end
  end

  context 'when ignore_cache is required' do
    let(:service_token_client) do
      described_class.new(application: 'some-key', namespace: 'some-namespace', ignore_cache: true)
    end
    before do
      Fb::Jwt::Auth.configure do |config|
        config.service_token_cache_api_version = :v3
      end
    end
    after do
      Fb::Jwt::Auth.configure do |config|
        config.service_token_cache_api_version = nil
      end
    end

    let(:public_key_uri) do
      URI('http://localhost:4000/v3/applications/some-key/namespaces/some-namespace?ignore_cache=true')
    end

    let(:response) do
      double(code: 200, body: JSON.generate(token: Base64.strict_encode64('R2D2')))
    end

    it 'should make a request with ignore_cache query param' do
      allow(Net::HTTP).to receive(:get_response).and_return(response)

      expect(Net::HTTP).to receive(:get_response).with(public_key_uri)
      service_token_client.public_key
    end
  end
end
