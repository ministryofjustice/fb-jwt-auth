RSpec.describe Fb::Jwt::Auth do
  describe '.configure' do
    after do
      Fb::Jwt::Auth.configure do |config|
        config.service_token_cache_root_url = nil
      end
    end

    it 'returns service token cache configuration' do
      Fb::Jwt::Auth.configure do |config|
        config.service_token_cache_root_url = 'http://localhost:4000'
      end

      expect(Fb::Jwt::Auth.service_token_cache_root_url).to eq('http://localhost:4000')
    end
  end
end
